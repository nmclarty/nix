{ config, inputs, ... }: {
  networking.firewall.allowedTCPPorts = [ 3493 ];
  sops.secrets."nut/admin".sopsFile =
    "${inputs.nix-private}/${config.networking.hostName}/secrets.yaml";
  power.ups = {
    mode = "netserver"; # override the default mode
    upsd.listen = [{ address = "0.0.0.0"; }];
    ups.primary = {
      driver = "usbhid-ups";
      port = "auto";
      description = "Cyberpower UPS - All servers";
      directives = [ "pollfreq = 5" "productid = 0601" ];
    };
    ups.ups = {
      driver = "dummy-ups";
      port = "primary@127.0.0.1";
      description = "Dummy UPS - For Synology";
    };
    # admin user for full access
    users.admin = {
      passwordFile = config.sops.secrets."nut/admin".path;
      actions = [ "SET" "FSD" ];
      instcmds = [ "ALL" ];
      upsmon = "primary";
    };
    # override the default monitor settings
    upsmon.monitor.primary = {
      passwordFile = config.sops.secrets."nut/admin".path;
      system = "primary@127.0.0.1";
      type = "primary";
      user = "admin";
    };
  };
}
