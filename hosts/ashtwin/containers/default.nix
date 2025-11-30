{ flake, ... }:
with flake.lib;
{
  imports = [
    ./garage
  ];
  users = containerUsers [
    { name = "garage"; id = 2000; }
  ];
}
