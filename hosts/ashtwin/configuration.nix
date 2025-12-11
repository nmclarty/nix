{ flake, inputs, config, pkgs, ... }: {
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
    ./samba.nix
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
    kernelModules = [ "kvm-intel" "i2c-dev" ];
  };

  # extra zpool
  sops.secrets."zfs/cold".sopsFile = "${inputs.nix-private}/${config.networking.hostName}/secrets.yaml";
  services.sanoid.datasets.cold = {
    useTemplate = [ "default" ];
    recursive = true;
  };

  # lights
  environment.systemPackages = with pkgs; [ i2c-tools ugreen-leds-cli ];
  systemd.services.ugreen-leds = {
    enable = true;
    wantedBy = [ "default.target" ];
    description = "Control system leds on startup";
    path = with pkgs; [
      ugreen-leds-cli
      i2c-tools
    ];
    script = ''
      set -euo pipefail
      ugreen_leds_cli all -off
      echo "Turned off all system leds"
    '';
  };
}
