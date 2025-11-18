{ inputs, flake, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    # standalone
    inputs.nixos-wsl.nixosModules.default
  ];
  
  # workaround to fix slow startup
  services.chrony.servers = [];

  # hardware
  networking = {
    hostName = "nevan-desktop";
    hostId = "f3a9e337";
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  wsl = {
    enable = true;
    defaultUser = "nmclarty";
    wslConf = {
      interop.enabled = false;
    };
  };
  system.stateVersion = "25.05";
}
