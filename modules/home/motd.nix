{ pkgs, flake, lib, osConfig, config, ... }:
let
  update-status = pkgs.writers.writePython3 "update-status" { }
    (builtins.readFile "${flake}/scripts/update-status.py");
  backup-status = pkgs.writers.writePython3 "backup-status" { }
    (builtins.readFile "${flake}/scripts/backup-status.py");

  # if we're managing containers declaratively using quadlet
  isEnabled = osConfig.virtualisation.quadlet.enable or false;
  # create a list of services without dashes in their names
  # (indicating that they are main containers, not dependencies)
  # and turn that list into rust-motd container entries
  containers =
    if isEnabled then
      lib.concatStringsSep "\n    "
        (map (s: "container display-name=\"${s}\" docker-name=\"/${s}\"")
          (lib.filter (s: ! lib.strings.hasInfix "-" s) (builtins.attrNames osConfig.virtualisation.quadlet.containers))
        ) else "";
  podman =
    if containers != "" then ''
      docker title="Podman" {
        ${containers}
      }
    ''
    else "";
in
{
  home.packages = with pkgs; [
    rust-motd
    figlet
    lolcat
  ];
  xdg = {
    # ensure the state dir exists, so cg_stats works
    stateFile."rust-motd/.empty".text = "";
    configFile."rust-motd/config.kdl".text =
      ''
        global {
          version "1.0"
          progress-empty-character "-"
        }
        components {
          command "hostname | figlet | lolcat -f"
          uptime prefix="Uptime:"
          load-avg format="Load (1, 5, 15 min.): {one:.02}, {five:.02}, {fifteen:.02}"
          cg-stats state-file="${config.xdg.stateHome}/rust-motd/cg_stats.toml" threshold=0.01
          ${podman}
          command color="light-white" "${update-status} ${flake} nixpkgs"
          command color="light-white" "${backup-status} local remote"
        }
      '';
  };
}
