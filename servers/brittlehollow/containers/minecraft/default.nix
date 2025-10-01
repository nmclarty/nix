{config, inputs, ...}: {
  imports = [ ./support.nix ./bluemap.nix ];
  users = import "${inputs.self}/lib/createUser.nix" {name = "minecraft"; id = 2005;};

  sops.secrets."minecraft/velocity/secret" = {
    sopsFile = "${inputs.nix-secrets}/${config.networking.hostName}/podman.yaml";
    key = "minecraft/velocity/secret";
  };
  sops.templates."minecraft/gate/config.yaml" = {
    restartUnits = [ "gate.service" ];
    owner = "minecraft";
    content = ''
      config:
        bind: 0.0.0.0:25565
        servers:
          survival: minecraft-survival:25565
          creative: minecraft-creative:25565
        try:
          - survival
          - creative
        status:
          motd : |
            hello from brittlehollow
          showMaxPlayers: 20
        forwarding:
          mode: velocity
          velocitySecret: '${config.sops.placeholder."minecraft/velocity/secret"}'
    '';
  };
  virtualisation.quadlet = {
    containers = {
      gate = {
        containerConfig = {
          image = "ghcr.io/minekube/gate:latest";
          autoUpdate = "registry";
          user = "2005:2005";
          volumes = [ "${config.sops.templates."minecraft/gate/config.yaml".path}:/config.yaml:ro" ];
          networks = [ "minecraft.network" ];
          publishPorts = [ "25565:25565" ];
        };
      };

      minecraft-survival = {
        containerConfig = {
          image = "docker.io/itzg/minecraft-server:stable";
          autoUpdate = "registry";
          user = "2005:2005";
          environments = {
            EULA = "TRUE";
            TYPE = "PAPER";
            VERSION = "1.21.4";
            MEMORY = "4G";
          };
          volumes = [ "/srv/minecraft/survival:/data" ];
          networks = [ "minecraft.network" ];
          healthCmd = "mc-health";
          healthStartupCmd = "sleep 30";
          healthOnFailure = "kill";
        };
      };

      minecraft-creative = {
        containerConfig = {
          image = "docker.io/itzg/minecraft-server:stable";
          autoUpdate = "registry";
          user = "2005:2005";
          environments = {
            EULA = "TRUE";
            TYPE = "PAPER";
            VERSION = "1.21.4";
            MEMORY = "4G";
          };
          volumes = [ "/srv/minecraft/creative:/data" ];
          networks = [ "minecraft.network" ];
          healthCmd = "mc-health";
          healthStartupCmd = "sleep 30";
          healthOnFailure = "kill";
        };
      };

    };
    networks = {
      minecraft = {};
    };
  };
}
