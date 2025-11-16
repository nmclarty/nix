{ flake, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    server.default
    # standalone
    standalone.server-disko
    inputs.disko.nixosModules.disko
  ];
  # hardware
  networking = {
    hostName = "timberhearth";
    hostId = "41bc3559";
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
  };
}
