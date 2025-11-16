{ inputs, flake, pkgs, ... }: {
  imports = [
    flake.modules.nixos.default
    flake.modules.server.default
    inputs.disko.nixosModules.disko
    ./disko.nix
  ];

  # hardware
  networking = {
    hostName = "embertwin";
    hostId = "c8cdbbba";
  };
  nixpkgs.hostPlatform = "aarch64-linux";
  boot = {
    # lts kernel lacks support for many rock 5b features
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [ "nvme" "usbhid" "usb_storage" "sr_mod" ];
  };
}
