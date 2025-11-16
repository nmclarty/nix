{
  programs = {
    # use nix-index for command-not-found
    nix-index.enable = true;
    # add comma for replacing nix shell
    nix-index-database.comma.enable = true;
  };
}
