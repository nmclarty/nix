{ inputs, flake, pkgs, ... }: {
  imports = [
    flake.modules.nixos.default
    flake.modules.server.default
    inputs.disko.nixosModules.disko
    ./disko.nix
  ];
  # architecture
  nixpkgs.hostPlatform = "aarch64-linux";
  # Network
  networking = {
    hostName = "embertwin";
    hostId = "c8cdbbba";
    useNetworkd = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
