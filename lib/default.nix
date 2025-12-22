{ inputs, ... }:
with inputs.nixpkgs.lib;
{
  # Creates a system user and group, commonly used for container users
  # - name (The name of the user)
  # - id (The uid/gid of the user)
  mkContainerUser = { name, id }: {
    users.${name} = {
      isSystemUser = true;
      description = "${name} container user";
      group = name;
      uid = id;
    };
    groups.${name}.gid = id;
  };

  mkContainerOptions = { name, id }: {
    enable = mkEnableOption "Enable ${name}";
    user = {
      name = mkOption {
        type = types.str;
        default = name;
        description = "The user to create and use for ${name}.";
      };
      id = mkOption {
        type = types.int;
        default = id;
        description = "The uid/gid for the user.";
      };
    };
  };
}
