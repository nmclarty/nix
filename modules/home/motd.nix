{ pkgs, flake, lib, osConfig, config, ... }:
let
  update-status = pkgs.writers.writePython3 "update-status" { }
    (builtins.readFile "${flake}/scripts/update-status.py");
  backup-status = pkgs.writers.writePython3 "backup-status" { }
    (builtins.readFile "${flake}/scripts/backup-status.py");
in
{
  config = lib.mkIf pkgs.stdenv.isLinux {
    home.packages = with pkgs; [
      rust-motd
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
            command color="light-white" "${update-status} ${flake} nixpkgs"
            command color="light-white" "${backup-status} local remote"
          }
        '';
    };
  };
}
