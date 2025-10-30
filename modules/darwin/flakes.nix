{ inputs, ... }: {
  imports = with inputs; [
    nix-private.darwinModules.private
  ];
  private.enable = true;
}
