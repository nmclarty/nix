{ config, inputs, ... }: {
  imports = [ ./support.nix ./config.nix ]; # redis, postgres, and config
  users = import "${inputs.self}/lib/createUser.nix" {
    name = "immich";
    id = 2004;
  }; # immich user
  virtualisation.quadlet = {
    containers = {
      immich = {
        containerConfig = {
          image = "ghcr.io/immich-app/immich-server:release";
          autoUpdate = "registry";
          user = "2004:2004";
          environments = {
            DB_PASSWORD_FILE = "/run/secrets/immich_postgres_password";
            REDIS_HOSTNAME = "immich-redis";
            DB_HOSTNAME = "immich-postgres";
            IMMICH_CONFIG_FILE = "/etc/immich/immich.json";
            IMMICH_WORKERS_INCLUDE = "api";
          };
          secrets = [ "immich_postgres_password,uid=2004,gid=2004,mode=0400" ];
          devices = [ "/dev/dri:/dev/dri" ];
          volumes = [
            "/srv/immich/library:/data"
            "${config.sops.templates."immich/config.json".path}:/etc/immich/immich.json:ro"
          ];
          networks = [ "immich.network" "exposed.network" ];
          labels = { "traefik.enable" = "true"; };
          healthCmd = "curl -fs http://127.0.0.1:2283/api/server/ping";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
        unitConfig = {
          Requires = [ "immich-redis.service" "immich-postgres.service" "immich-learning.service" "immich-microservices.service" ];
          After = [ "immich-redis.service" "immich-postgres.service" "immich-learning.service" "immich-microservices.service" ];
        };
      };

      immich-microservices = {
        containerConfig = {
          image = "ghcr.io/immich-app/immich-server:release";
          autoUpdate = "registry";
          user = "2004:2004";
          environments = {
            DB_PASSWORD_FILE = "/run/secrets/immich_postgres_password";
            REDIS_HOSTNAME = "immich-redis";
            DB_HOSTNAME = "immich-postgres";
            IMMICH_CONFIG_FILE = "/etc/immich/immich.json";
            IMMICH_WORKERS_EXCLUDE = "api";
          };
          secrets = [ "immich_postgres_password,uid=2004,gid=2004,mode=0400" ];
          devices = [ "/dev/dri:/dev/dri" ];
          volumes = [
            "/srv/immich/library:/data"
            "${config.sops.templates."immich/config.json".path}:/etc/immich/immich.json:ro"
          ];
          networks = [ "immich.network" ];
          healthCmd = "true";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
        unitConfig = {
          Requires = [ "immich-redis.service" "immich-postgres.service" "immich-learning.service" ];
          After = [ "immich-redis.service" "immich-postgres.service" "immich-learning.service" ];
        };
        serviceConfig.AllowedCPUs = "12-19";
      };

      immich-learning = {
        containerConfig = {
          image = "ghcr.io/immich-app/immich-machine-learning:release-openvino";
          autoUpdate = "registry";
          userns = "auto:uidmapping=0:2004:1,gidmapping=0:2004:1";
          environments = { MACHINE_LEARNING_MODEL_INTRA_OP_THREADS = "2"; };
          podmanArgs = [ "--device-cgroup-rule=c 189:* rmw" ];
          devices = [ "/dev/dri:/dev/dri" ];
          volumes =
            [ "/dev/bus/usb:/dev/bus/usb" "immich-learning-cache:/cache" ];
          networks = [ "immich.network" ];
          healthCmd = "bash -c 'echo -n > /dev/tcp/127.0.0.1/3003'";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
        serviceConfig.AllowedCPUs = "12-19";
      };
    };
    networks = { immich = { }; };
  };
}
