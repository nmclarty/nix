{ inputs, flake, ... }: {
  imports = with inputs; [
    quadlet-nix.nixosModules.quadlet
    sops-nix.nixosModules.sops
    lanzaboote.nixosModules.lanzaboote
    nix-private.nixosModules.private
  ];
  private.enable = true;
}
