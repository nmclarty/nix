{lib, ...}: {
  imports = [
    ./garage
  ];
  users =
    (lib.createUser { name = "garage"; id = 2006; });
}
