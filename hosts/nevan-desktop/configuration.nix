{ inputs, perSystem, ... }: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];
  wsl = {
    enable = true;
    defaultUser = "nmclarty";
  };
  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";
  # home manager
  home-manager.extraSpecialArgs = { inherit (perSystem) unstable; };
}
