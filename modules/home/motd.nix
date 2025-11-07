{ pkgs, unstable, flake, lib, osConfig, config, ... }:
let
  last-updated = pkgs.writeScriptBin "last-updated" ''
    #!${pkgs.python3}/bin/python3
    import json, datetime, sys

    def diff(channel):
      now = datetime.datetime.now()
      then = datetime.datetime.fromtimestamp(data["nodes"][channel]["locked"]["lastModified"])
      return [channel, now - then]
    
    # path to the comin (gitops) status file
    status_path = "/var/lib/comin/status.json"
    # the flake inputs to check
    inputs = sys.argv[1:]
    # path to the lock file
    flake_path = "${flake}/flake.lock"

    with open(status_path, "r") as file:
      status = json.load(file)
    
    with open(flake_path, "r") as file:
      data = json.load(file)

    last = map(diff, inputs)

    print("Update status:")
    print(f'  Message: {status["COMIN_GIT_MSG"]} ({status["COMIN_GIT_SHA"][:7]})')
    for i in last:
      print(f'  {i[0]}: {str(i[1])[:-7]} ago')
  '';

  backup-status = pkgs.writeScriptBin "backup-status" ''
    #!${pkgs.python3}/bin/python3
    import json, datetime, sys

    profiles = sys.argv[1:]
    status_path = "/var/lib/resticprofile"

    def get_status(profile):
      try:
        with open(f'{status_path}/{profile}.status', "r") as file:
          data = json.load(file)
      except FileNotFoundError:
        print("  N/A")
        exit()
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
  config = lib.mkIf pkgs.platform.isLinux {
    home.packages = with pkgs; [
      unstable.rust-motd
      figlet
      lolcat
    ];
    xdg = {
      # ensure the state dir exists, so cg_stats works
      stateFile."rust-motd/.empty".text = "";
      configFile."rust-motd/config.kdl".text =
        let
          # creates a list of services without dashes in their names (only main, not their dependencies)
          # and turns that list into rust-motd container entries
          containers = lib.concatStringsSep "\n    "
            (map (s: "container display-name=\"${s}\" docker-name=\"/${s}\"")
              (lib.filter (s: ! lib.strings.hasInfix "-" s) (builtins.attrNames osConfig.virtualisation.quadlet.containers)));
        in
        ''
          global {
            version "1.0"
            progress-empty-character "-"
          }
          components {
            command "hostname | figlet | lolcat -f"
            filesystems {
              filesystem name="nix" mount-point="/nix"
              filesystem name="services" mount-point="/srv"
            }
            uptime prefix="Uptime:"
            load-avg format="Load (1, 5, 15 min.): {one:.02}, {five:.02}, {fifteen:.02}"
            cg-stats state-file="${config.xdg.stateHome}/rust-motd/cg_stats.toml" threshold=0.01
            docker title="Podman" {
              ${containers}
            }
            command color="light-white" "${last-updated}/bin/last-updated nixpkgs unstable"
            command color="light-white" "${backup-status}/bin/backup-status local remote"
          }
        '';
    };
  };
}
