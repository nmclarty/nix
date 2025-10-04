{ pkgs, pkgs-unstable, inputs, ... }: 
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

    print("Last updated:")
    for i in last:
      print(f'  {i[0]}: {str(i[1])[:-7]} ago')
  '';
in 
{
  #environment.systemPackages = with pkgs-unstable; [ rust-motd figlet lolcat python3];
  systemd.services.rust-motd = {
    description = "Update the motd using rust-motd";
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ pkgs-unstable.rust-motd pkgs.bash pkgs.hostname pkgs.figlet pkgs.lolcat pkgs.python3 last-updated ];
    script = ''
      mkdir -p /var/lib/rust-motd
      while true; do
        rust-motd /etc/rust-motd/config.kdl > /run/motd
        sleep 300
      done
    '';
  };
  environment.etc."rust-motd/config.kdl".text = ''
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
      service-status {
        service display-name="Tailscale" unit="tailscaled"
      }
      command "last-updated stable unstable"
    }
  '';
}
