{ flake, lib, config, ... }:
with lib;
with flake.lib;
let
  cfg = config.apps.forgejo;
  # the user id (in string form) is used a lot by quadlet,
  # so create a variable for ease of use
  id = toString cfg.user.id;
in
{
  options.apps.forgejo = {
    enable = mkEnableOption "Enable Forgejo";
    user = {
      name = mkOption {
        type = types.str;
        default = "forgejo";
        description = "The user to create and use for Forgejo.";
      };
      id = mkOption {
        type = types.int;
        default = 2000;
        description = "The uid/gid for the user.";
      };
    };
  };

  config = mkIf config.apps.forgejo.enable {
    # user
    users = mkContainerUser cfg.user.name cfg.user.id;

    # dirs
    systemd.tmpfiles.settings.forgejo = {
      "/srv/forgejo/data".d = { user = id; group = id; };
    };

    # containers
    virtualisation.quadlet = {
      containers = {
        forgejo = {
          containerConfig = mkContainer {
            image = "codeberg.org/forgejo/forgejo:13-rootless";
            user = "${id}:${id}";
            volumes = [ "/srv/forgejo/data:/var/lib/gitea" ];
            publishPorts = [
              "3000:3000"
              "22:2222"
            ];
            healthCmd = "wget -O /dev/null -q -T 5 http://127.0.0.1:3000";
          };
        };
      };
    };
  };
}
