{ inputs, flake, ... }: {
  imports = with flake.modules; [
    # standalone
    inputs.nixos-wsl.nixosModules.default
  ];
  # hardware
  wsl = {
    enable = true;
    defaultUser = "nmclarty";
  };
  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";
}
