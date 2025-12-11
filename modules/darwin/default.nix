{
  imports = [
    # shared modules
    ../shared/default.nix
    # darwin specific modules
    ./flakes.nix
    ./homebrew.nix
    ./system.nix
  ];
}
