{perSystem, ...}: {
  environment.systemPackages = with perSystem.unstable; [
    go
    nodejs_24
    yarn-berry
    gdal
  ];
}
