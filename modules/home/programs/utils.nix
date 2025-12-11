{
  programs = {
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };

    difftastic = {
      enable = true;
      git.enable = true;
    };

    nh = {
      enable = true;
      flake = "$HOME/projects/nix";
    };

    micro = {
      enable = true;
      settings = {
        clipboard = "terminal";
        mkparents = true;
        scrollbar = true;
      };
    };
  };
}
