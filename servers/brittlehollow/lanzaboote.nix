{ lib, pkgs-unstable, ... }: {
  # sbctl to manage keys and for debugging
  environment.systemPackages = [ pkgs-unstable.sbctl ];
  boot = {
    # lanzaboote replaces systemd-boot
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };
}
