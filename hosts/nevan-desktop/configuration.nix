{ inputs, flake, ... }: {
  imports = with flake.modules; [
    # profiles
    nixos.default
    # standalone
    inputs.nixos-wsl.nixosModules.default
  ];

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
      interop = {
        enabled = true;
        appendWindowsPath = false;
      };
    };
  };
  system.stateVersion = "25.05";
}
