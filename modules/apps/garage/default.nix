{ flake, lib, config, ... }:
with lib;
with flake.lib;
let
  cfg = config.apps.garage;
  id = toString cfg.user.id;
in
{
  imports = [ ./config.nix ];
  options.apps.garage = mkContainerOptions { name = "garage"; id = 2001; };
  config = mkIf cfg.enable {
    # user
    users = mkContainerUser { inherit (cfg.user) name id; };

    # dirs
    systemd.tmpfiles.rules = [
      "d /srv/garage/meta - ${id} ${id}"
      "d /cold/garage/data - ${id} ${id}"
    ];

    # containers
    virtualisation.quadlet.containers.garage.containerConfig = {
      image = "docker.io/dxflrs/garage:v2.1.0";
      autoUpdate = "registry";
      user = "${id}:${id}";
      networks = [ "host" ];
      environments = {
        GARAGE_RPC_SECRET_FILE = "/run/secrets/garage_rpc";
      };
      secrets = [ "garage_rpc,uid=${id},gid=${id},mode=0400" ];
      volumes = [
        "${config.sops.templates."garage/garage.toml".path}:/etc/garage.toml:ro"
        "/srv/garage/meta:/var/lib/garage/meta"
        "/cold/garage/data:/var/lib/garage/data"
      ];
    };
  };
}
