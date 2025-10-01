{ config, pkgs, ... }: {
  virtualisation.quadlet = {
    containers = {
      seafile-mariadb = {
        containerConfig = {
          image = "docker.io/library/mariadb:10.11";
          autoUpdate = "registry";
          user = "2003:2003";
          environments = {
            MARIADB_AUTO_UPGRADE = "true";
            MARIADB_ROOT_PASSWORD_FILE = "/run/secrets/seafile_mariadb_root";
          };
          secrets = [ "seafile_mariadb_root,uid=2003,gid=2003,mode=0400" ];
          volumes = [ "/srv/seafile/mariadb:/var/lib/mysql" ];
          networks = [ "seafile.network" ];
          healthCmd =
            "healthcheck.sh --connect --mariadbupgrade --innodb_initialized";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };
      seafile-memcached = {
        containerConfig = {
          image = "docker.io/library/memcached:1.6";
          autoUpdate = "registry";
          user = "2003:2003";
          networks = [ "seafile.network" ];
          healthCmd = "bash -c 'echo -n > /dev/tcp/127.0.0.1/11211'";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };
    };
  };
}
