{pkgs, osConfig, ...}: {
  home = {
    stateVersion = "25.05";
    username = "nmclarty";
    homeDirectory = "/home/nmclarty";
    packages = with pkgs; [
      # general utilities
      gdu
      micro
      wget
      doggo
      moreutils
      yq-go
      difftastic
      nh
      # for backups
      resticprofile
      # for secrets
      sops
      pwgen
    ];
  };
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
  };
}
