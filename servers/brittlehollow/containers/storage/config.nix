{inputs, config, ...}: {
  sops = {
    secrets = {
      "storage/seafile/secret" = {
        sopsFile = "${inputs.nix-secrets}/${config.networking.hostName}/podman.yaml";
        key = "storage/seafile/secret";
      };
      "storage/seafile/oauth/client" = {
        sopsFile = "${inputs.nix-secrets}/${config.networking.hostName}/podman.yaml";
        key = "storage/seafile/oauth/client";
      };
      "storage/seafile/oauth/secret" = {
        sopsFile = "${inputs.nix-secrets}/${config.networking.hostName}/podman.yaml";
        key = "storage/seafile/oauth/secret";
      };
    };

    templates = {
      "seafile/seafile.conf" = {
        restartUnits = [ "seafile.service" ];
        owner = "storage";
        content = ''
          [quota]
          default = 250

          [history]
          keep_days = 30

          [fileserver]
          port = 8082
          use_go_fileserver = true
        '';
      };

      "seafile/seahub_settings.py" = {
        restartUnits = [ "seafile.service" ];
        owner = "storage";
        content = ''
          SECRET_KEY = "${config.sops.placeholder."storage/seafile/secret"}"
          TIME_ZONE = "Etc/UTC"

          # customization settings
          SITE_TITLE = "Seafile"

          # library settings
          ENCRYPTED_LIBRARY_VERSION = 4
          ENCRYPTED_LIBRARY_PWD_HASH_ALGO = "argon2id"
          ENCRYPTED_LIBRARY_PWD_HASH_PARAMS = "2,102400,8"
          ENABLE_REPO_SNAPSHOT_LABEL = True

          # oidc settings for pocket id integration
          ENABLE_OAUTH = True
          CLIENT_SSO_VIA_LOCAL_BROWSER = True
          OAUTH_CLIENT_ID = "${config.sops.placeholder."storage/seafile/oauth/client"}"
          OAUTH_CLIENT_SECRET = "${config.sops.placeholder."storage/seafile/oauth/secret"}"
          OAUTH_REDIRECT_URL = "https://seafile.${config.private.domain}/oauth/callback/"
          OAUTH_PROVIDER = "pocket-id"
          OAUTH_AUTHORIZATION_URL = "https://pocket.${config.private.domain}/authorize"
          OAUTH_TOKEN_URL = "https://pocket.${config.private.domain}/api/oidc/token"
          OAUTH_USER_INFO_URL = "https://pocket.${config.private.domain}/api/oidc/userinfo"
          OAUTH_SCOPE = [ "openid", "email", "profile" ]
          OAUTH_ATTRIBUTE_MAP = {
              "sub": (True, "uid"),
              "name": (False, "name"),
              "email": (False, "contact_email")
          }
        '';
      };

      "seafile/seafevents.conf" = {
        restartUnits = [ "seafile.service" ];
        owner = "storage";
        content = ''
          [STATISTICS]
          enabled=true

          [SEAHUB EMAIL]
          enabled = true
          interval = 30m

          [FILE HISTORY]
          enabled = true
          suffix = md,txt,doc,docx,xls,xlsx,ppt,pptx,sdoc
        '';
      };

      "seafile/seafdav.conf" = {
        restartUnits = [ "seafile.service" ];
        owner = "storage";
        content = ''
          [WEBDAV]
          enabled = false
          port = 8080
          share_name = /seafdav
        '';
      };

      "seafile/gunicorn.conf.py" = {
        restartUnits = [ "seafile.service" ];
        owner = "storage";
        content = ''
          import os

          daemon = True
          workers = 5

          # default localhost:8000
          bind = "127.0.0.1:8000"

          # Pid
          pids_dir = '/opt/seafile/pids'
          pidfile = os.path.join(pids_dir, 'seahub.pid')

          # for file upload, we need a longer timeout value (default is only 30s, too short)
          timeout = 1200

          limit_request_line = 8190

          # for forwarder headers
          forwarder_headers = 'SCRIPT_NAME,PATH_INFO,REMOTE_USER'
        '';
      };
    };
  };
}
