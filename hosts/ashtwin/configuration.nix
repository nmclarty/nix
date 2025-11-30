{ flake, inputs, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    server.default
    # standalone
    disko.mirror
    inputs.disko.nixosModules.disko
  ];

  # hardware
  hardware = {
    hostName = "ashtwin";
    hostId = "43c12ddf";
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-intel" ];
  };
}
