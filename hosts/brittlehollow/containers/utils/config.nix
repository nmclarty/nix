{ config, ... }: {
  sops = {
    templates = {
      "utils/traefik.yaml" = {
        restartUnits = [ "traefik.service" ];
        owner = "utils";
        content = ''
          global:
            sendAnonymousUsage: true
          log:
            level: INFO
          ping:
            entryPoint: traefik

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
    };
  };
}
