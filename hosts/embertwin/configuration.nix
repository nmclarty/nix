{ inputs, flake, pkgs, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    server.default
    # standalone
    disko.sbc
    inputs.disko.nixosModules.disko
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
