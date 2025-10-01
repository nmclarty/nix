{config, ...}: {
  environment.etc = {
    "config/traefik.yaml".text = ''
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

      providers:
        docker:
          endpoint: "tcp://socket-proxy:2375"
          exposedByDefault: false
          network: "exposed"
          defaultRule: "Host(`{{ normalize .ContainerName }}.${config.private.domain}`)"
      
      api:
        dashboard: true
        insecure: true
        debug: true

      certificatesResolvers:
        cloudflare:
          acme:
            storage: /data/acme.json
            dnsChallenge:
              provider: cloudflare
    '';
    "config/homepage.yaml".text = ''
    '';
  };
}
