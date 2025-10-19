{ inputs, system, ... }: {
  imports = with inputs; [
    quadlet-nix.nixosModules.quadlet
    sops-nix.nixosModules.sops
    home-manager.nixosModules.home-manager
    nix-private.nixosModules.private
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nmclarty = "${inputs.self}/home.nix";
  };
  private.enable = true;
}
