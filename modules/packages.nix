{ pkgs, pkgs-unstable, ... }: {
  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # packages
  environment.systemPackages = with pkgs; [
    btop
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
    gcc
    jq
    sops
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

      if not set -q FISH_INITIALIZED
        set -gx FISH_INITIALIZED 1
        fix_ssh_auth_sock
        env_vars
        cat /run/motd 2>/dev/null | head -n -1 || true
      end
    '';
  };
  programs.nix-ld.enable = true;

  # services
  services.tailscale = {
    enable = true;
    openFirewall = true;
    package = pkgs-unstable.tailscale;
    useRoutingFeatures = "server";
  };
  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };

  # sudo
  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR"
  '';
}
