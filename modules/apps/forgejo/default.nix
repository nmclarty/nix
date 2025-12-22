{ flake, lib, config, ... }:
with lib;
with flake.lib;
let
  cfg = config.apps.forgejo;
  id = toString cfg.user.id;
in
{
  options.apps.forgejo = mkContainerOptions { name = "forgejo"; id = 2000; };
  config = mkIf cfg.enable {
    # user
    users = mkContainerUser { inherit (cfg.user) name id; };

    # dirs
    systemd.tmpfiles.rules = [
      "d /srv/forgejo/data - ${id} ${id}"
    ];

    # containers
    virtualisation.quadlet.containers.forgejo.containerConfig = {
      image = "codeberg.org/forgejo/forgejo:13-rootless";
      autoUpdate = "registry";
      user = "${id}:${id}";
      volumes = [ "/srv/forgejo/data:/var/lib/gitea" ];
      publishPorts = [
        "3000:3000"
        "22:2222"
      ];
      healthCmd = "wget -O /dev/null -q -T 5 http://127.0.0.1:3000";
      healthStartupCmd = "sleep 10";
      healthOnFailure = "kill";
    };
  };
}
