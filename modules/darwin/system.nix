{ perSystem, ...}: {
  # version
  system.stateVersion = 6;
  # nix settings
  nix = {
    # for determinate nix
    enable = false;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };
  # set arch
  nixpkgs.hostPlatform = "aarch64-darwin";
  # pam
  security.pam.services.sudo_local.touchIdAuth = true;
  # users
  users.users.nmclarty.home = "/Users/nmclarty";
  system.primaryUser = "nmclarty";
  # fish
  programs.fish.enable = true;
  # home manager
  home-manager.extraSpecialArgs = { unstable = perSystem.unstable; };
}
