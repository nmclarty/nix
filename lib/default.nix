_:
{
  # Creates a system user and group, commonly used for container users
  # - name (The name of the user)
  # - id (The uid/gid of the user)
  mkContainerUser = name: id: {
    users.${name} = {
      isSystemUser = true;
      description = "${name} container user";
      group = name;
      uid = id;
    };
    groups.${name}.gid = id;
  };

  mkContainer = config: config // {
    autoUpdate = "registry";
    healthStartupCmd = "sleep 10";
    healthOnFailure = "kill";
  };
}
