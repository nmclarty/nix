{ inputs, pkgs, ... }: {
  # comma (nix shell alternative)
  imports = [ inputs.nix-index-database.homeModules.default ];
  programs.nix-index-database.comma.enable = true;

  # extra packages
  home.packages = with pkgs; [
    # languages
    python3
    nodejs
    go
    # tools
    gh
    shellcheck
    # nix
    nixd
    statix
    deadnix
    nixpkgs-fmt
  ];
}
