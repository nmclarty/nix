{lib, ...}: {
  imports = [
    ./garage
  ];
  users =
    (lib.conUser { name = "garage"; id = 2006; });
}
