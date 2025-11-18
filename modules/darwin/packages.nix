{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    yarn-berry
    gdal
    kubectl
    kubelogin-oidc
    colima
  ];
}
