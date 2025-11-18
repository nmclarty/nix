{ inputs, ... }: {
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
        disks_filter = "/ /srv /nix ";
        swap_disk = false;
        use_fstab = false;
        disk_free_priv = true;
        show_coretemp = false;
        proc_per_core = true;
      };
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = "Nevan McLarty";
          email = "37232202+nmclarty@users.noreply.github.com";
        };
        init.defaultBranch = "main";
        gpg.ssh.defaultKeyCommand = "ssh-add -L";
      };
      signing = {
        format = "ssh";
        signByDefault = true;
      };
    };
    difftastic = {
      enable = true;
      git.enable = true;
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
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
            "github.com" = {
              hostname = "ssh.github.com";
              port = 443;
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
          # load homebrew environment variables, but override them to end of $PATH
          eval ($brew shellenv | string replace -r '(fish_add_path)' '$1 --append')
        end
      '';
      loginShellInit = ''
        # env vars
        set -gx EDITOR micro
        set -gx NH_FLAKE ~/projects/nix/

        # motd (remove empty lines)
        if type -q rust-motd; and test "$TERM_PROGRAM" != "vscode"
          rust-motd | grep -v '^$'
        end
      '';
      shellAbbrs = {
        # general
        ll = "eza -lh --git";
        la = "eza -lh --git --all";
        lt = "eza -lh --git --tree --git-ignore --total-size";
        # docker
        dc = "docker compose";
        de = "docker exec -it";
      };
      functions = {
        fish_greeting = "";
        fish_prompt = ''
          echo -n "$(hostname | lolcat -f)"
          set_color brgreen; echo -n " [$(basename $PWD)]";
          set_color bryellow; echo -n " > ";
        '';
        helper-health = "sudo podman inspect $argv[1] | yq -oj '.[0].State.Health'";
        helper-ps = "sudo podman ps --format='table {{.Names}}\t{{.Status}}\t{{.Image}}'";
        helper-hostid = "head -c4 /dev/urandom | xxd -p";
        helper-logs = ''
          cat /srv/utils/traefik/logs/access.log \
          | grep "$argv[1]@docker" (if test (count $argv) -eq 0; echo "-v"; end) \
          | goaccess --log-format TRAEFIKCLF
        '';
      };
    };
  };
}
