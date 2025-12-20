{ flake, inputs, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    server.default
    # standalone
    disko.single
    inputs.disko.nixosModules.disko
    # hardware
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
  ];

  # hardware
  networking = {
    hostName = "darkbramble";
    hostId = "4895e382";
  };
  nixpkgs.hostPlatform = "aarch64-linux";
  boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" ];
  disko.devices.disk.primary.device = "/dev/sda";
}
