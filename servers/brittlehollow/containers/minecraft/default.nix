{ config, inputs, ... }: {
  imports = [ ./support.nix ./bluemap.nix ];
  users = import "${inputs.self}/lib/createUser.nix" {
    name = "minecraft";
    id = 2005;
  };
  sops.templates."minecraft/velocity/velocity.toml" = {
    restartUnits = [ "velocity.service" ];
    owner = "minecraft";
    content = ''
      config-version = "2.7"
      bind = "0.0.0.0:25565"
      motd = "<green><b>the earth says hello!</b></green>\nsurvival | creative"
      show-max-players = 20
      online-mode = true
      force-key-authentication = true
      prevent-client-proxy-connections = false
      player-info-forwarding-mode = "modern"
      forwarding-secret-file = "/run/secrets/minecraft_velocity_secret"
      announce-forge = false
      kick-existing-players = false
      ping-passthrough = "none"
      enable-player-address-logging = true

      [servers]
      survival = "minecraft-survival:25565"
      creative = "minecraft-creative:25565"
      try = [ "survival", "creative" ]

      [forced-hosts]
      "survival.obsidiantech.ca" = [ "survival" ]
      "creative.obsidiantech.ca" = [ "creative" ]

      [advanced]
      compression-threshold = 256
      compression-level = -1
      login-ratelimit = 3000
      connection-timeout = 5000
      read-timeout = 30000
      haproxy-protocol = false
      tcp-fast-open = false
      bungee-plugin-message-channel = true
      show-ping-requests = false
      failover-on-unexpected-server-disconnect = true
      announce-proxy-commands = true
      log-command-executions = false
      log-player-connections = true
      accepts-transfers = false

      [query]
      enabled = false
      port = 25577
      map = "Velocity"
      show-plugins = false
    '';
  };

  virtualisation.quadlet = {
    containers = {
      velocity = {
        containerConfig = {
          image = "docker.io/itzg/mc-proxy:stable";
          autoUpdate = "registry";
          user = "2005:2005";
          environments = {
            TYPE = "VELOCITY";
          };
          secrets = [ "minecraft_velocity_secret,uid=2005,gid=2005,mode=0400" ];
          volumes = [ 
            "/srv/minecraft/velocity:/server"
            "${config.sops.templates."minecraft/velocity/velocity.toml".path}:/server/velocity.toml:ro"
          ];
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

      minecraft-biomes = {
        containerConfig = {
          image = "docker.io/itzg/minecraft-server:stable";
          autoUpdate = "registry";
          user = "2005:2005";
          environments = {
            EULA = "TRUE";
            TYPE = "FORGE";
            VERSION = "1.20.1";
            FORGE_VERSION = "47.4.9";
            INIT_MEMORY = "2G";
            MAX_MEMORY = "8G";
          };
          volumes = [ "/srv/minecraft/biomes:/data" ];
          networks = [ "minecraft.network" ];
          publishPorts = [ "25566:25565" ];
          healthCmd = "mc-health";
          healthStartupCmd = "sleep 30";
          healthOnFailure = "kill";
        };
      };

    };
    networks = { minecraft = { }; };
  };
}
