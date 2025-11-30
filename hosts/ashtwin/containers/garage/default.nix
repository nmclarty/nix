{ config, ... }: {
  imports = [ ./config.nix ];
  virtualisation.quadlet = {
    containers = {
      garage = {
        containerConfig = {
          image = "docker.io/dxflrs/garage:v2.1.0";
          autoUpdate = "registry";
          user = "2000:2000";
          networks = [ "host" ];
          environments = {
            GARAGE_RPC_SECRET_FILE = "/run/secrets/garage_rpc";
          };
          secrets = [ "garage_rpc,uid=2000,gid=2000,mode=0400" ];
          volumes = [
            "${config.sops.templates."garage/garage.toml".path}:/etc/garage.toml:ro"
            "/srv/garage/meta:/var/lib/garage/meta"
            "/cold/garage/data:/var/lib/garage/data"
          ];
        };
      };
    };
  };
}
