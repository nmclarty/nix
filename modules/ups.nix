{lib, config, inputs, ...}: {
  sops.secrets."nut/monuser".sopsFile = "${inputs.nix-secrets}/secrets.yaml";
  power.ups = {
    enable = true;
    mode = lib.mkDefault "netclient";
    # basic user for monitoring only
    users.monuser = {
      passwordFile = config.sops.secrets."nut/monuser".path;
      upsmon = "secondary";
    };
    upsmon.monitor.primary = {
      passwordFile = lib.mkDefault config.sops.secrets."nut/monuser".path;
      system = lib.mkDefault "primary@brittlehollow";
      type = lib.mkDefault "secondary";
      user = lib.mkDefault "monuser";
    };
  };
}
