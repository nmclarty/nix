{ inputs, ... }: {
  imports = with inputs; [
    quadlet-nix.nixosModules.quadlet
    sops-nix.nixosModules.sops
    home-manager.nixosModules.home-manager
    lanzaboote.nixosModules.lanzaboote
    nix-private.nixosModules.private
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nmclarty = "${inputs.self}/home";
  };
  private.enable = true;
}
