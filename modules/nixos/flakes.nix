{ inputs, ... }: {
  imports = with inputs; [
    nix-index-database.nixosModules.nix-index
  ];
}
