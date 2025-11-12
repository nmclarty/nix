{ flake, pkgs, ... }: {
  imports = [
    flake.modules.nixos.default
    flake.modules.server.default
    ./disko.nix
  ];
  # Network
  networking = {
    hostName = "embertwin";
    hostId = "c8cdbbba";
    useNetworkd = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
