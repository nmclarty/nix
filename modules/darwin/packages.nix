{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    go
    nodejs_24
    yarn-berry
    gdal
    kubectl
    kubelogin-oidc
  ];
}
