{ flake, lib, config, ... }:
with flake.lib;
let
  cfg = config.apps.pocket;
  id = toString cfg.user.id;
in
{
  config = lib.mkIf cfg.enable {
    # user
    users = mkContainerUser { inherit (cfg.user) name id; };

    # dirs
    systemd.tmpfiles.rules = [
      "d /srv/pocket - ${id} ${id}"
    ];

    # containers
    virtualisation.quadlet.containers.pocket = {
      containerConfig = {
        image = "ghcr.io/pocket-id/pocket-id:${cfg.tag}";
        autoUpdate = "registry";
        user = "${id}:${id}";
        environments = {
          APP_URL = "https://pocket.${config.apps.domain}";
          TRUST_PROXY = "true";
          MAXMIND_LICENSE_KEY_FILE = "/run/secrets/pocket_maxmind";
          ENCRYPTION_KEY_FILE = "/run/secrets/pocket_encryption";
        };
        secrets = [
          "pocket_maxmind,uid=${id},gid=${id},mode=0400"
          "pocket_encryption,uid=${id},gid=${id},mode=0400"
        ];
        volumes = [ "/srv/pocket:/app/data" ];
        networks = [ "exposed.network" ];
        labels = { "traefik.enable" = "true"; };
        healthCmd = "/app/pocket-id healthcheck";
        healthStartupCmd = "sleep 10";
        healthOnFailure = "kill";
      };
    };
  };
}
