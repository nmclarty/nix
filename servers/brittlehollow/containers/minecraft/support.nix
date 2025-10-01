{
  virtualisation.quadlet = {
    containers = {
      minecraft-mariadb = {
        containerConfig = {
          image = "docker.io/library/mariadb:10.11";
          autoUpdate = "registry";
          user = "2005:2005";
          environments = {
            MARIADB_AUTO_UPGRADE = "true";
            MARIADB_DATABASE = "minecraft";
            MARIADB_USER = "minecraft";
            MARIADB_ROOT_PASSWORD_FILE = "/run/secrets/minecraft_mariadb_root";
            MARIADB_PASSWORD_FILE = "/run/secrets/minecraft_mariadb_password";
          };
          secrets = [ 
            "minecraft_mariadb_root,uid=2005,gid=2005,mode=0400"
            "minecraft_mariadb_password,uid=2005,gid=2005,mode=0400"
          ];
          volumes = [ "/srv/minecraft/mariadb:/var/lib/mysql" ];
          networks = [ "minecraft.network" ];
          healthCmd = "healthcheck.sh --connect --mariadbupgrade --innodb_initialized";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };
    };
  };
}
