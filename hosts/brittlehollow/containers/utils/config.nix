{ inputs, config, ... }: {
  sops = {
    secrets = {
      "utils/traefik/token" = {
        sopsFile = "${inputs.nix-private}/${config.networking.hostName}/podman.yaml";
        key = "utils/traefik/token";
      };
    };
    templates = {
      "utils/traefik/traefik.yaml" = {
        restartUnits = [ "traefik.service" ];
        owner = "utils";
        content = ''
          global:
            sendAnonymousUsage: true
          log:
            level: INFO
          ping:
            entryPoint: http
          accessLog:
            filePath: /data/logs/access.log

          entryPoints:
            http:
              address: :80
              http:
                redirections:
                  entryPoint:
                    to: https
                    scheme: https
            https:
              address: :443
              asDefault: true
              http:
                middlewares:
                  - security@file
                tls:
                  certResolver: cloudflare
                  domains:
                    - main: "${config.private.domain}"
                      sans:
                        - "*.${config.private.domain}"
              # fix for immich timeouts
              transport:
                respondingTimeouts:
                  readTimeout: "0s"

          providers:
            file:
              filename: /etc/traefik/dynamic.yaml
            docker:
              endpoint: "tcp://socket-proxy:2375"
              exposedByDefault: false
              network: "exposed"
              allowEmptyServices: true
              defaultRule: "Host(`{{ normalize .ContainerName }}.${config.private.domain}`)"

          api:
            dashboard: true
            disabledashboardad: true

          certificatesResolvers:
            cloudflare:
              acme:
                storage: /data/acme.json
                dnsChallenge:
                  provider: cloudflare
        '';
      };
      "utils/traefik/dynamic.yaml" = {
        restartUnits = [ "traefik.service" ];
        owner = "utils";
        content = ''
          http:
            middlewares:
              security:
                headers:
                  contentTypeNosniff: true
                  frameDeny: true
                  stsSeconds: 63072000
                  stsIncludeSubdomains: true
                  referrerPolicy: "strict-origin-when-cross-origin"
                  customResponseHeaders:
                    server: ""
                    x-powered-by: ""
        '';
      };

      "utils/ddclient/ddclient.conf" = {
        restartUnits = [ "ddclient.service" ];
        owner = "utils";
        content = ''
          # general
          daemon=300
          # syslog=yes
          # ssl=yes

          # router
          usev4=webv4
          usev6=webv6

          # protocol
          protocol=cloudflare, \
          zone=${config.private.domain}, \
          login=token, \
          password=${config.sops.placeholder."utils/traefik/token"} \
          *.${config.private.domain}
        '';
      };
    };
  };
}
