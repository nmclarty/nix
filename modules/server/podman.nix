{ config, pkgs, inputs, ... }: {
  # import flake modules
  imports = with inputs; [
    quadlet-nix.nixosModules.quadlet
    nix-private.nixosModules.private
  ];
  # enable private options
  private.enable = true;
  sops.secrets."podman.yaml" = {
    sopsFile = "${inputs.nix-private}/${config.networking.hostName}/podman.yaml";
    key = "";
  };
  system.activationScripts.podman-secrets = {
    deps = [ "setupSecrets" ];
    text = ''
      add_secrets() {
        PATH="${pkgs.podman}/bin:${pkgs.yq-go}/bin:$PATH";
        echo "[podman-secrets] adding secrets to store..."
        podman secret rm --all 1>/dev/null
        while IFS='=' read -r key val; do
          echo "$val" | podman secret create "$key" - 1>/dev/null
        done < <(yq -os . ${config.sops.secrets."podman.yaml".path})
      }
      add_secrets || true
    '';
  };
  systemd.services.podman.environment.LOGGING = "--log-level=warn"; # reduce log spam
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune = {
        enable = true;
        flags = [ "--all" ];
      };
    };
    quadlet = {
      enable = true;
      autoUpdate = {
        enable = true;
        calendar = "weekly";
      };
    };
  };
  # for rootful userns
  users.users.containers = {
    isSystemUser = true;
    autoSubUidGidRange = true;
    group = "containers";
  };
  users.groups.containers = { };
}
