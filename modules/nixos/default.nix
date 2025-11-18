{
  imports = [
    # shared modules
    ../shared/default.nix
    # nixos specific modules
    ./packages.nix
    ./system.nix
    ./secrets.nix
    ./flakes.nix
    ./users.nix
  ];
}
