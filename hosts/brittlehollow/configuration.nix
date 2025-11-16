{ inputs, config, flake, ... }: {
  imports = [
    flake.modules.nixos.default
    flake.modules.server.default
    ./containers
    ./ups.nix
    ./lanzaboote.nix
  ];

  # hardware
  networking = {
    hostName = "brittlehollow";
    hostId = "012580f6";
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
  boot = {
    initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
  };

  # extra zpool
  sops.secrets."zfs/tank".sopsFile = "${inputs.nix-private}/${config.networking.hostName}/secrets.yaml";
  boot.zfs.extraPools = [ "tank" ];
  services.sanoid.datasets.tank = {
    useTemplate = [ "default" ];
    recursive = true;
  };

  # enable containers from private repo
  private.containers.enable = true;
}
