{ config, flake, ... }:
let
  # short git rev for the version label (i.e. "6669da0" or "6669da0-dirty")
  shortRev = flake.shortRev or flake.dirtyShortRev or "unknown";
  # nixos date from the version suffix (i.e. "20251122")
  nixDate = builtins.substring 1 8 config.system.nixos.versionSuffix;
in
{
  system = {
    stateVersion = "25.05";
    # the full git ref that the system was built from
    configurationRevision = flake.rev or flake.dirtyRev or "unknown";
    # the label combining the nixos release and date, and with git ref of the flake commit
    nixos.label = with config.system.nixos; release + "-" + nixDate + ":git-" + shortRev;
  };

  # locale
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  services.xserver.xkb.layout = "us";

  # enable nonfree firmware
  hardware.enableRedistributableFirmware = true;

  # use zram for memory compression
  zramSwap.enable = true;

  # nix settings
  sops.templates."nix/access-token" = {
    owner = "nmclarty";
    content = ''
      access-tokens = github.com=${config.sops.placeholder."github/token"}
    '';
  };
  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
    extraOptions = ''
      !include ${config.sops.templates."nix/access-token".path}
    '';
  };
}
