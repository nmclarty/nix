{ flake, ... }: {
  imports = [
    flake.modules.darwin.default
  ];
  # hostname (to remove the .local suffix)
  networking.hostName = "nevan-macbook";
  # arch
  nixpkgs.hostPlatform = "aarch64-darwin";
}
