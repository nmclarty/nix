# Creates a system user and group, commonly used for container users
# - name: the user and group name
# - id: the uid and gid
{ name, id }: {
  users.${name} = {
    isSystemUser = true;
    description = "${name} container user";
    group = name;
    uid = id;
  };
  groups.${name}.gid = id;
}
