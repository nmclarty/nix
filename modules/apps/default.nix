{ lib, config, ... }:
with lib;
{
  imports = [
    ./forgejo
    ./garage
    ./immich
    ./seafile
  ];
  options.apps.domain = mkOption {
    type = types.str;
    default = config.private.domain;
    description = "The domain name to use for all apps.";
  };
}
