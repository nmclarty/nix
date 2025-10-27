{
  # version
  system.stateVersion = 6;
  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # set arch
  nixpkgs.hostPlatform = "aarch64-darwin";
  # pam
  security.pam.services.sudo_local.touchIdAuth = true;
  # users
  users.users.nmclarty.home = "/Users/nmclarty";
  system.primaryUser = "nmclarty";
  # fish
  programs.fish.enable = true;
}
