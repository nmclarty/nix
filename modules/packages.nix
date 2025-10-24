{ pkgs-unstable, ... }: {
  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # packages
  # environment.systemPackages = with pkgs; [ ];

  # programs
  programs = {
    fish = {
      enable = true;
      loginShellInit = ''
        # because pam_ssh_agent_auth doesn't like symlinks
        function fix_ssh_auth_sock
          if test -L "$SSH_AUTH_SOCK"
            set -gx SSH_AUTH_SOCK (readlink -f $SSH_AUTH_SOCK)
          end
        end

        function env_vars
          set -gx fish_greeting ""
          set -gx EDITOR micro
          set -gx NH_FLAKE ~/nix/
        end

        fix_ssh_auth_sock
        env_vars
        if status is-login
          cat /run/motd 2>/dev/null | head -n -1 | grep -v '^$'
        end
      '';
    };
    # to fix vscode remote development
    nix-ld.enable = true;
    # command-not-found doesn't work with flakes
    command-not-found.enable = false;
  };

  # services
  systemd.services.tailscaled.serviceConfig.LogLevelMax = "notice";
  services = {
    # clean up lingering apps on ssh session loss
    logind.killUserProcesses = true;
    # remote access
    tailscale = {
      enable = true;
      openFirewall = true;
      package = pkgs-unstable.tailscale;
      useRoutingFeatures = "server";
    };
    sanoid = {
      enable = true;
      templates.default = {
        hourly = 24;
        daily = 7;
        monthly = 0;
        yearly = 0;
        autosnap = true;
        autoprune = true;
      };
      datasets.zroot = {
        useTemplate = [ "default" ];
        recursive = true;
        processChildrenOnly = true;
      };
    };
  };

  # sudo
  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR"
  '';
}
