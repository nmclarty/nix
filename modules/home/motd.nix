{ pkgs, lib, osConfig, config, inputs, ... }:
# optional/extra feature configurations
let
  cgStats =
    if pkgs.stdenv.isLinux then ''
      cg-stats state-file="${config.xdg.stateHome}/rust-motd/cg_stats.toml" threshold=0.01
    '' else "";

  conNames = builtins.attrNames (osConfig.virtualisation.quadlet.containers or { });
  # create a list of services without dashes in their names
  # (indicating that they are main containers, not dependencies)
  # and turn that list into rust-motd container entries
  containers =
    if conNames != [ ] then
      lib.concatStringsSep "\n    "
        (map (s: ''container display-name="${s}" docker-name="/${s}"'')
          (lib.filter (s: ! lib.strings.hasInfix "-" s) conNames)
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
  imports = with inputs; [
    py_motd.homeModules.py_motd
  ];
  programs.py_motd = {
    enable = true && pkgs.stdenv.isLinux;
    settings = {
      update.inputs = [ "nixpkgs" "nix-private" "py_motd" ];
      backup.profiles = [ "local" "remote" ];
    };
  };
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
          uptime prefix="Uptime:"
          load-avg format="Load (1, 5, 15 min.): {one:.02}, {five:.02}, {fifteen:.02}"
          ${cgStats}
          ${podman}
        }
      '';
  };
}
