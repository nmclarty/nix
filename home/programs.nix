{ osConfig, ... }: {
  programs = {
    btop = {
      enable = true;
      settings = {
        graph_symbol = "block";
        update_ms = 1000;
        proc_sorting = "cpu direct";
        proc_tree = true;
        proc_gradient = false;
        proc_filter_kernel = true;
        proc_aggregate = true;
        disks_filter = "/ /nix /srv /home";
        swap_disk = false;
        use_fstab = false;
        disk_free_priv = true;
      };
    };
    git = {
      enable = true;
      userName = "Nevan McLarty";
      userEmail = osConfig.private.git.email;
      signing = {
        format = "ssh";
        signByDefault = true;
        key = osConfig.sops.secrets."nmclarty/ssh/remote".path;
      };
      extraConfig = {
        init.defaultBranch = "main";
        gpg.ssh.allowedSignersFile = osConfig.sops.templates."git/allowed_signers".path;
      };
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        # because pam_ssh_agent_auth doesn't like symlinks
        if test -L "$SSH_AUTH_SOCK"
          set -gx SSH_AUTH_SOCK (readlink -f $SSH_AUTH_SOCK)
        end
      '';
      loginShellInit = ''
        # env vars
        set -gx fish_greeting ""
        set -gx EDITOR micro
        set -gx NH_FLAKE ~/nix/

        # motd
        if status is-login
          cat /run/motd 2>/dev/null | head -n -1 | grep -v '^$'
        end
      '';
      functions = {
        helper-health = "sudo podman inspect $argv[1] | yq -oj '.[0].State.Health'";
      };
    };
  };
}
