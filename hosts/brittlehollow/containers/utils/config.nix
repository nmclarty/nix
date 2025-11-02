{ config, ... }: {
  sops = {
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
            entryPoint: traefik
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
    };
  };
}
