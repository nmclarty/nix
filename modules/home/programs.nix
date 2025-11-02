{ osConfig, inputs, ... }: {
  programs = {
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };
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
        show_coretemp = false;
      };
    };
    git = {
      enable = true;
      userName = "Nevan McLarty";
      userEmail = osConfig.private.git.email;
      difftastic.enable = true;
      signing = {
        format = "ssh";
        signByDefault = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        gpg.ssh.defaultKeyCommand = "ssh-add -L";
      };
    };
    ssh = {
      enable = true;
      matchBlocks =
        let
          # get all the hosts
          hosts = builtins.attrNames inputs.self.nixosConfigurations;
          # generate configuration for each that allows agent forwarding
          generatedBlocks = builtins.listToAttrs (
            map
              (host: {
                name = host;
                value = {
                  forwardAgent = true;
                };
              })
              hosts
          );
          # add manual config for hosts that aren't managed by nix
          manualBlocks = {
            ashtwin = { forwardAgent = true; };
            ics226 = {
              user = "student";
              forwardAgent = true;
            };
          };
        in
        # combine both and set the config option
        generatedBlocks // manualBlocks;
    };
    fish = {
      enable = true;
      interactiveShellInit = ''
        # set up ssh auth socket
        set op_sock ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
        if test -S $op_sock
          # if 1password agent socket exists, use it
          set -gx SSH_AUTH_SOCK $op_sock
        else if test -L "$SSH_AUTH_SOCK"
          # if we're running remotely via ssh, resolve the symlink
          set -gx SSH_AUTH_SOCK (readlink -f $SSH_AUTH_SOCK)
        end

        # load homebrew env
        set brew /opt/homebrew/bin/brew
        if test -f $brew
          eval ($brew shellenv)
        end
      '';
      loginShellInit = ''
        # env vars
        set -gx EDITOR micro
        set -gx NH_FLAKE ~/projects/nix/

        # motd
        if status is-login; and test -f /run/motd
          cat /run/motd 2>/dev/null | head -n -1 | grep -v '^$'
        end
      '';
      functions = {
        fish_greeting = "";
        fish_prompt = ''set_color green; echo -n "($(basename $PWD)) > "'';
        helper-health = "sudo podman inspect $argv[1] | yq -oj '.[0].State.Health'";
        helper-logs = ''
          cat /srv/utils/traefik/logs/access.log \
          | grep "$argv[1]@docker" (if test (count $argv) -eq 0; echo "-v"; end) \
          | goaccess --log-format TRAEFIKCLF
        '';
      };
    };
  };
}
