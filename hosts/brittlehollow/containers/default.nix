{ flake, ... }:
with flake.lib;
{
  imports = [
    ./immich
    ./utils
    ./minecraft
    ./storage
  ];
  # users = mkContainerUsers [
  #   { name = "utils"; id = 2002; }
  #   { name = "storage"; id = 2003; }
  #   { name = "immich"; id = 2004; }
  #   { name = "minecraft"; id = 2005; }
  # ];
}
