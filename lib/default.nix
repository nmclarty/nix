{ flake, ... }:
let
  conUser = { name, id }: {
    name = name;
    value = {
      isSystemUser = true;
      description = "${name} container user";
      group = name;
      uid = id;
    };
  };
  conGroup = { name, id }: {
    inherit name;
    value = {
      gid = id;
    };
  };
in
with builtins;
{
  # Creates a set of system users and groups, commonly used for container users
  # - users: a list of attribute sets with `name` and `id` keys
  containerUsers = users: {
    users = listToAttrs (map conUser users);
    groups = listToAttrs (map conGroup users);
  };
}
