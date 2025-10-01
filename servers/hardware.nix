{ config, lib, pkgs, modulesPath, ... }: {
  # extra hardware configuration
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # kernel modules
  boot.initrd.availableKernelModules =
    [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # filesystems to mount
  fileSystems = {
    "/" = {
      device = "zroot/nixos";
      fsType = "zfs";
    };
    "/nix" = {
      device = "zroot/nixos/nix";
      fsType = "zfs";
    };
    "/var/cache" = {
      device = "zroot/nixos/cache";
      fsType = "zfs";
    };
    "/var/lib/containers" = {
      device = "zroot/nixos/containers";
      fsType = "zfs";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  # enable dhcp for all interfaces by default
  networking.useDHCP = lib.mkDefault true;

  # enable microcode updates
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # enable systemd boot
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      configurationLimit = 5;
      enable = true;
    };
  };
}
