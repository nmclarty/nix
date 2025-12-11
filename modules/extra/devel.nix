{ pkgs, ... }: {
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
