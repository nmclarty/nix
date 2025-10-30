{
  virtualisation.quadlet = {
    containers = {
      storage-mariadb = {
        containerConfig = {
          image = "docker.io/library/mariadb:10.11";
          autoUpdate = "registry";
          user = "2003:2003";
          environments = {
            MARIADB_AUTO_UPGRADE = "true";
            MARIADB_ROOT_PASSWORD_FILE = "/run/secrets/storage_mariadb_root";
          };
          secrets = [ "storage_mariadb_root,uid=2003,gid=2003,mode=0400" ];
          volumes = [ "/srv/storage/mariadb:/var/lib/mysql" ];
          networks = [ "storage.network" ];
          healthCmd = "healthcheck.sh --connect --mariadbupgrade --innodb_initialized";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };

      storage-redis = {
        containerConfig = {
          image = "docker.io/library/redis:8.2";
          autoUpdate = "registry";
          user = "2003:2003";
          entrypoint = [ "sh" "-c" "redis-server --requirepass $(cat /run/secrets/storage_redis_password)" ];
          secrets = [ "storage_redis_password,uid=2003,gid=2003,mode=0400" ];
          volumes = [ "/srv/storage/redis:/data" ];
          networks = [ "storage.network" ];
          healthCmd = "redis-cli ping";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };
    };
  };
}
