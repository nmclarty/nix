{ config, pkgs, ... }: {
  virtualisation.quadlet = {
    containers = {
      immich-redis = {
        containerConfig = {
          image = "docker.io/valkey/valkey:8-bookworm";
          autoUpdate = "registry";
          user = "2004:2004";
          volumes = [ "/srv/immich/redis:/data" ];
          networks = [ "immich.network" ];
          healthCmd = "redis-cli ping";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };
      immich-postgres = {
        containerConfig = {
          image =
            "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
          autoUpdate = "registry";
          user = "2004:2004";
          shmSize = "128mb";
          environments = {
            POSTGRES_USER = "postgres";
            POSTGRES_DB = "immich";
            POSTGRES_PASSWORD_FILE = "/run/secrets/immich_postgres_password";
            POSTGRES_INITDB_ARGS = "--data-checksums";
          };
          secrets = [ "immich_postgres_password,uid=2004,gid=2004,mode=0400" ];
          volumes = [ "/srv/immich/postgres:/var/lib/postgresql/data" ];
          networks = [ "immich.network" ];
          healthCmd = "pg_isready";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };
    };
  };
}
