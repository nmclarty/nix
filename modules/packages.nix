{ pkgs, pkgs-unstable, ... }: {
  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # packages
  environment.systemPackages = with pkgs; [
    pkgs-unstable.btop
    gdu
    micro
    git
    wget
    doggo
    resticprofile
    moreutils
    intel-gpu-tools
    yq-go
    difftastic
    openssl
    jq
    sops
    nh
  ];

  # programs
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # because pam_ssh_agent_auth doesn't like symlinks
      function fix_ssh_auth_sock
        if test -L "$SSH_AUTH_SOCK"
          set -gx SSH_AUTH_SOCK (readlink -f $SSH_AUTH_SOCK)
        end
      end

      function env_vars
        set -gx fish_greeting ""
        set -gx EDITOR micro
        set -gx NIXOS_CONFIG ~/nix/
      end

      fix_ssh_auth_sock
      env_vars
      if status is-login
        cat /run/motd 2>/dev/null | head -n -1 | grep -v '^$'
      end
    '';
  };
  programs.nix-ld.enable = true;
  # command-not-found doesn't work with flakes
  programs.command-not-found.enable = false;

  # services
  systemd.services.tailscaled.serviceConfig.LogLevelMax = "notice";
  services.tailscale = {
    enable = true;
    openFirewall = true;
    package = pkgs-unstable.tailscale;
    useRoutingFeatures = "server";
  };
  # to avoid lingering apps on ssh session loss
  services.logind.killUserProcesses = true;

  # sudo
  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR"
  '';
}
