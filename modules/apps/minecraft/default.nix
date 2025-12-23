{ flake, lib, config, ... }:
with flake.lib;
let
  cfg = config.apps.minecraft;
  id = toString cfg.user.id;
in
{
  imports = [ ./config.nix ];
  config = lib.mkIf cfg.enable {
    # user
    users = mkContainerUser
  };
}
