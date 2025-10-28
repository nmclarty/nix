{ inputs, config, ... }: {
  imports = [ ./config.nix ./support.nix ];
  users = import "${inputs.self}/lib/createUser.nix" { name = "storage"; id = 2003; };
  virtualisation.quadlet = {
    containers = {
      seafile = {
        containerConfig = {
          image = "docker.io/seafileltd/seafile-mc:13.0-latest";
          autoUpdate = "registry";
          userns = "auto:uidmapping=0:2003:1,gidmapping=0:2003:1";
          environments = rec {
            SEAFILE_MYSQL_DB_HOST = "storage-mariadb";
            SEAFILE_MYSQL_DB_PORT = "3306";
            SEAFILE_MYSQL_DB_USER = "seafile";
            SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
            SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
            SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";
            SEAFILE_SERVER_HOSTNAME = "seafile.${config.private.domain}";
            SEAFILE_SERVER_PROTOCOL = "https";
            SITE_ROOT = "/";
            NON_ROOT = "false";
            SEAFILE_LOG_TO_STDOUT = "true";
            ENABLE_SEADOC = "false";
            SEADOC_SERVER_URL = "${SEAFILE_SERVER_PROTOCOL}://${SEAFILE_SERVER_HOSTNAME}/sdoc-server";
            CACHE_PROVIDER = "redis";
            REDIS_HOST = "storage-redis";
            REDIS_PORT = "6379";
            ENABLE_NOTIFICATION_SERVER = "true";
            INNER_NOTIFICATION_SERVER_URL = "http://storage-notification:8083";
            NOTIFICATION_SERVER_URL = "${SEAFILE_SERVER_PROTOCOL}://${SEAFILE_SERVER_HOSTNAME}/notification";
            ENABLE_SEAFILE_AI = "false";
            SEAFILE_AI_SERVER_URL = "http://storage-ai:8888";
            MD_FILE_COUNT_LIMIT = "100000";
          };
          secrets = [
            "storage_mariadb_root,type=env,target=INIT_SEAFILE_MYSQL_ROOT_PASSWORD"
            "storage_mariadb_password,type=env,target=SEAFILE_MYSQL_DB_PASSWORD"
            "storage_seafile_email,type=env,target=INIT_SEAFILE_ADMIN_EMAIL"
            "storage_seafile_password,type=env,target=INIT_SEAFILE_ADMIN_PASSWORD"
            "storage_seafile_jwt,type=env,target=JWT_PRIVATE_KEY"
            "storage_redis_password,type=env,target=REDIS_PASSWORD"
          ];
          volumes = [
            "/srv/storage/logs:/shared/logs"
            "/srv/storage/nginx:/shared/nginx"
            "/srv/storage/seafile:/shared/seafile"
            "${config.sops.templates."seafile/seafile.conf".path}:/shared/seafile/conf/seafile.conf:ro"
            "${config.sops.templates."seafile/seahub_settings.py".path}:/shared/seafile/conf/seahub_settings.py:ro"
            "${config.sops.templates."seafile/seafevents.conf".path}:/shared/seafile/conf/seafevents.conf:ro"
            "${config.sops.templates."seafile/seafdav.conf".path}:/shared/seafile/conf/seafdav.conf:ro"
            "${config.sops.templates."seafile/gunicorn.conf.py".path}:/shared/seafile/conf/gunicorn.conf.py:ro"
          ];
          networks = [ "storage.network" "exposed.network" ];
          labels = { "traefik.enable" = "true"; };
          healthCmd = "wget -O - -q -T 5 127.0.0.1:8000/api2/ping";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
        unitConfig = {
          Requires = [ "storage-mariadb.service" "storage-redis.service" ];
          After = [ "storage-mariadb.service" "storage-redis.service" ];
        };
      };

      storage-notification = {
        containerConfig = {
          image = "docker.io/seafileltd/notification-server:13.0-latest";
          autoUpdate = "registry";
          environments = {
            SEAFILE_MYSQL_DB_HOST = "storage-mariadb";
            SEAFILE_MYSQL_DB_PORT = "3306";
            SEAFILE_MYSQL_DB_USER = "seafile";
            SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
            SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
            SEAFILE_LOG_TO_STDOUT = "true";
            NOTIFICATION_SERVER_LOG_LEVEL = "info";
          };
          secrets = [
            "storage_mariadb_password,type=env,target=SEAFILE_MYSQL_DB_PASSWORD"
            "storage_seafile_jwt,type=env,target=JWT_PRIVATE_KEY"
          ];
          volumes = [ "/srv/storage/seafile/logs:/shared/seafile/logs" ];
          networks = [ "exposed.network" "storage.network" ];
          labels = {
            "traefik.enable" = "true";
            "traefik.http.services.storage-notification.loadbalancer.server.port" = "8083";
            "traefik.http.routers.storage-notification.rule" =
              "Host(`seafile.${config.private.domain}`) && PathPrefix(`/notification`)";
          };
          healthCmd = "bash -c 'echo -n > /dev/tcp/127.0.0.1/8083'";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
        unitConfig = {
          Requires = [ "storage-mariadb.service" ];
          After = [ "storage-mariadb.service" ];
        };
      };
    };

    networks = {
      storage = { };
    };
  };
}
