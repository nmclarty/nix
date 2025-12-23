{ lib, config, ... }:
with lib;
{
  imports = [
    ./forgejo
    ./garage
    ./immich
    ./minecraft
    ./pocket
    ./seafile
    ./tinyauth
    ./traefik
  ];
  options.apps = {
    # global
    domain = mkOption {
      type = types.str;
      default = config.private.domain;
      description = "The domain name to use for all apps.";
    };
    # apps
  } // mkContainerOptions [
    { id = 2000; name = "forgejo"; tag = "13-rootless"; }
    { id = 2001; name = "garage"; tag = "v2.1.0"; }
    { id = 2002; name = "immich"; tag = "release"; }
    { id = 2003; name = "seafile"; tag = "13.0-latest"; }
    { id = 2004; name = "traefik"; tag = "v3"; }
    { id = 2005; name = "pocket"; tag = "v1"; }
    { id = 2006; name = "tinyauth"; tag = "v4"; }
    { id = 2007; name = "minecraft"; tag = "stable"; }
  ];
}
