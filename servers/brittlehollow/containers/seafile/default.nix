{ config, inputs, ... }: {
  imports = [ ./support.nix ]; # mariadb and memcached
  users = import "${inputs.self}/lib/createUser.nix" {
    name = "seafile";
    id = 2003;
  };
  virtualisation.quadlet = {
    containers = {
      seafile = {
        containerConfig = {
          image = "docker.io/seafileltd/seafile-mc:12.0-latest";
          autoUpdate = "registry";
          environments = {
            DB_HOST = "mariadb";
            DB_PORT = "3306";
            DB_USER = "seafile";
            SEAFILE_MYSQL_DB_CCNET_DB_NAME = "ccnet_db";
            SEAFILE_MYSQL_DB_SEAFILE_DB_NAME = "seafile_db";
            SEAFILE_MYSQL_DB_SEAHUB_DB_NAME = "seahub_db";
            SEAFILE_SERVER_HOSTNAME = "seafile.${config.private.domain}";
            SEAFILE_SERVER_PROTOCOL = "https";
            SITE_ROOT = "/";
            NON_ROOT = "false";
            SEAFILE_LOG_TO_STDOUT = "true";
            ENABLE_SEADOC = "false";
            #SEADOC_SERVER_URL=${SEAFILE_SERVER_PROTOCOL:-http}://${SEAFILE_SERVER_HOSTNAME:?Variable is not set or empty}/sdoc-server
          };
          secrets = [
            "seafile_mariadb_root,type=env,target=DB_ROOT_PASSWD"
            "seafile_mariadb_password,type=env,target=DB_PASSWORD"
            "seafile_email,type=env,target=INIT_SEAFILE_ADMIN_EMAIL"
            "seafile_password,type=env,target=INIT_SEAFILE_ADMIN_PASSWORD"
            "seafile_jwt,type=env,target=JWT_PRIVATE_KEY"
          ];
          volumes = [ "/srv/seafile/shared:/shared" ];
          networks = [ "seafile.network" "exposed.network" ];
          labels = { "traefik.enable" = "true"; };
          healthCmd = "wget -O - -q -T 5 127.0.0.1:8000/api2/ping";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
        unitConfig = {
          Requires = [ "seafile-mariadb.service" "seafile-memcached.service" ];
          After = [ "seafile-mariadb.service" "seafile-memcached.service" ];
        };
      };
    };
    networks = { seafile = { }; };
  };
}
