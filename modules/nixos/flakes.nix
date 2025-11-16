{ inputs, ... }: {
  imports = with inputs; [
    nix-index-database.darwinModules.nix-index
  ];
}
