{ pkgs, pkgs-unstable, inputs, lib, config, ... }: 
let
  last-updated = pkgs.writeScriptBin "last-updated" ''
    #!${pkgs.python3}/bin/python3
    import json, datetime, sys

    inputs = sys.argv[1:]
    flake_path = "${inputs.self}/flake.lock"

    with open(flake_path, "r") as file:
      data = json.load(file)

    def diff(channel):
      now = datetime.datetime.now()
      then = datetime.datetime.fromtimestamp(data["nodes"][channel]["locked"]["lastModified"])
      return [channel, now - then]

    last = map(diff, inputs)

    print("Nixpkgs updated:")
    for i in last:
      print(f'  {i[0]}: {str(i[1])[:-7]} ago')
  '';
  backup-status = pkgs.writeScriptBin "backup-status" ''
    #!${pkgs.python3}/bin/python3
    import json, datetime, sys

    profiles = sys.argv[1:]
    status_path = "/var/lib/resticprofile"

    def get_status(profile):
      with open(f'{status_path}/{profile}.status', "r") as file:
        data = json.load(file)
      status = data["profiles"][profile]["backup"]
      status["profile"] = profile
      return status

    def diff(time):
      now = datetime.datetime.now()
      then = datetime.datetime.fromisoformat(time).replace(tzinfo=None)
      return now - then

    statuses = map(get_status, profiles)
    status_labels = ["Failure", "Success"]

    print("Backup status:")
    for status in statuses:
      time_ago = diff(status["time"])
      print(f'  {status["profile"]}: ({status_labels[status["success"]]}) {str(time_ago)[:-7]} ago')
  '';
in 
{
  #environment.systemPackages = with pkgs-unstable; [ rust-motd figlet lolcat python3];
  systemd.services.rust-motd = {
    description = "Update the motd using rust-motd";
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ pkgs-unstable.rust-motd pkgs.bash pkgs.hostname pkgs.figlet pkgs.lolcat pkgs.python3 ];
    script = ''
      mkdir -p /var/lib/rust-motd
      while true; do
        rust-motd /etc/rust-motd/config.kdl > /run/motd
        sleep 300
      done
    '';
  };
  environment.etc."rust-motd/config.kdl".text = let
    # creates a list of services without dashes in their names (only main, not their dependencies)
    services = lib.filter (s: ! lib.strings.hasInfix "-" s) (builtins.attrNames config.virtualisation.quadlet.containers);
    # turns that list into rust-motd container entries
    containers = lib.concatStringsSep "\n    " (map (s: "container display-name=\"${s}\" docker-name=\"/${s}\"") services);
    in ''
    global {
      version "1.0"
      progress-empty-character "-"
    }
    components {
      command "hostname | figlet | lolcat -f | head -n -1"
      uptime prefix="Uptime:"
      load-avg format="Load (1, 5, 15 min.): {one:.02}, {five:.02}, {fifteen:.02}"
      memory swap-pos="below"
      filesystems {
        filesystem name="nix" mount-point="/nix"
        filesystem name="services" mount-point="/srv"
      }
      cg-stats state-file="/var/lib/rust-motd/cg_stats.toml" threshold=0.01
      docker {
        ${containers}
      }
      command "${last-updated}/bin/last-updated stable unstable"
      command "${backup-status}/bin/backup-status local remote"
    }
  '';
}
