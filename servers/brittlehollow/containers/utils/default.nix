{ config, inputs, pkgs, ... }: {
  imports = [ ./config.nix ]; # traefik config
  users = import "${inputs.self}/lib/createUser.nix" {
    name = "utils";
    id = 2002;
  };
  virtualisation.quadlet = {
    containers = {
      traefik = {
        containerConfig = {
          image = "docker.io/library/traefik:v3";
          autoUpdate = "registry";
          user = "2002:2002";
          environments = {
            CF_DNS_API_TOKEN_FILE = "/run/secrets/utils_traefik_token";
          };
          secrets = [ "utils_traefik_token,uid=2002,gid=2002,mode=0400" ];
          volumes = [
            "/etc/config/traefik.yaml:/etc/traefik/traefik.yaml:ro"
            "/srv/utils/traefik:/data"
          ];
          sysctl."net.ipv4.ip_unprivileged_port_start" = "80";
          publishPorts = [ "80:80" "443:443" "8080:8080" ];
          networks = [ "socket-proxy" "exposed:ip=10.90.0.2" ];
          healthCmd = "traefik healthcheck";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
        unitConfig = {
          Wants = [ "socket-proxy.service" ];
          After = [ "socket-proxy.service" ];
        };
      };

      socket-proxy = {
        containerConfig = {
          image = "lscr.io/linuxserver/socket-proxy:latest";
          autoUpdate = "registry";
          readOnly = true;
          tmpfses = [ "/tmp" ];
          environments = {
            CONTAINERS = "1";
            LOG_LEVEL = "notice";
          };
          volumes = [ "/var/run/docker.sock:/var/run/docker.sock:ro" ];
          networks = [ "socket-proxy.network" ];
          healthCmd = "wget -O - -q -T 5 http://127.0.0.1:2375/_ping";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };

      speed = {
        containerConfig = {
          image = "docker.io/openspeedtest/latest:latest";
          autoUpdate = "registry";
          networks = [ "exposed.network" ];
          labels = { "traefik.enable" = "true"; };
          healthCmd = "wget --spider -T 5 http://127.0.0.1:3000";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };

      homepage = {
        containerConfig = {
          image = "ghcr.io/gethomepage/homepage:latest";
          autoUpdate = "registry";
          user = "2002:2002";
          publishPorts = [ "3000:3000" ];
          environments = {
            "HOMEPAGE_ALLOWED_HOSTS" = "${config.networking.hostName}:3000";
          };
          volumes = [ "/srv/utils/homepage:/app/config" ];
          healthCmd = "wget -O - -q -T 5 http://127.0.0.1:3000/api/healthcheck";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };

      pocket = {
        containerConfig = {
          image = "ghcr.io/pocket-id/pocket-id:v1";
          autoUpdate = "registry";
          user = "2002:2002";
          environments = {
            APP_URL = "https://pocket.${config.private.domain}";
            TRUST_PROXY = "true";
            MAXMIND_LICENSE_KEY_FILE = "/run/secrets/utils_pocket_maxmind";
            ENCRYPTION_KEY_FILE = "/run/secrets/utils_pocket_encryption";
          };
          secrets = [
            "utils_pocket_maxmind,uid=2002,gid=2002,mode=0400"
            "utils_pocket_encryption,uid=2002,gid=2002,mode=0400"
          ];
          volumes = [ "/srv/utils/pocket:/app/data" ];
          networks = [ "exposed.network" ];
          labels = { "traefik.enable" = "true"; };
          healthCmd = "/app/pocket-id healthcheck";
          healthStartupCmd = "sleep 10";
          healthOnFailure = "kill";
        };
      };

      tinyauth = {
        containerConfig = {
          image = "ghcr.io/steveiliop56/tinyauth:v4";
          autoUpdate = "registry";
          user = "2002:2002";
          environments = {
            # general
            APP_URL = "https://tinyauth.${config.private.domain}";
            OAUTH_AUTO_REDIRECT = "pocketid";
            # pocket-id oauth
            PROVIDERS_POCKETID_CLIENT_SECRET_FILE = "/run/secrets/utils_tinyauth_secret";
            PROVIDERS_POCKETID_AUTH_URL = "https://pocket.${config.private.domain}/authorize";
            PROVIDERS_POCKETID_TOKEN_URL = "https://pocket.${config.private.domain}/api/oidc/token";
            PROVIDERS_POCKETID_USER_INFO_URL = "https://pocket.${config.private.domain}/api/oidc/userinfo";
            PROVIDERS_POCKETID_SCOPES = "openid email profile groups";
            PROVIDERS_POCKETID_NAME="Pocket ID";
          };
          secrets = [
            "utils_tinyauth_client,type=env,target=PROVIDERS_POCKETID_CLIENT_ID"
            "utils_tinyauth_secret,uid=2002,gid=2002,mode=0400"
          ];
          networks = [ "exposed.network" ];
          labels = {
            "traefik.enable" = "true";
            "traefik.http.middlewares.tinyauth.forwardauth.address" = "http://tinyauth:3000/api/auth/traefik";
          };
        };
      };

    };
    networks = {
      socket-proxy.networkConfig.internal = true;
      exposed.networkConfig = {
        subnets = [ "10.90.0.0/24" ];
        ipRanges = [ "10.90.0.5-10.90.0.254" ];
      };
    };
  };
}
