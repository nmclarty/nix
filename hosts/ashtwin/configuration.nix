{ flake, inputs, config, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    server.default
    # standalone
    disko.mirror
    disko.cold
    inputs.disko.nixosModules.disko
    # host
    ./containers
  ];

  # hardware
  networking = {
    hostName = "ashtwin";
    hostId = "43c12ddf";
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-intel" ];
  };

  # extra zpool
  sops.secrets."zfs/cold".sopsFile = "${inputs.nix-private}/${config.networking.hostName}/secrets.yaml";
  services.sanoid.datasets.cold = {
    useTemplate = [ "default" ];
    recursive = true;
  };
}
