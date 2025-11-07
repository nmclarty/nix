{ config, pkgs, inputs, perSystem, ... }: {
  sops.secrets."podman.yaml" = {
    sopsFile =
      "${inputs.nix-private}/${config.networking.hostName}/podman.yaml";
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
  systemd.services.podman.environment.LOGGING =
    "--log-level=warn"; # reduce log spam
  virtualisation = {
    containers = {
      enable = true;
      containersConf.settings = {
        # containers.log_driver = "k8s-file";
        engine.events_logger = "file";
        secrets = {
          driver = "shell";
          opts = {
            list = "true";
            lookup = ''printf $(yq .$(yq -r ".idToName.$SECRET_ID" /var/lib/containers/storage/secrets/secrets.json | tr '_' '.') ${config.sops.secrets."podman.yaml".path})'';
            store = "true";
            delete = "true";
          };
        };
      };
    };
    podman = {
      enable = true;
      package = perSystem.unstable.podman;
      autoPrune.enable = true;
      dockerSocket.enable = true;
      extraPackages = [
        pkgs.yq-go
        pkgs.coreutils
        pkgs.iptables
      ]; # yq and tr (coreutils) for parsing secrets, iptables for creating pods (doesn't work without it?)
    };
    quadlet = {
      autoEscape = true;
      autoUpdate.enable = true;
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

