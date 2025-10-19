{ inputs, system, ... }: {
  imports = with inputs; [
    quadlet-nix.nixosModules.quadlet
    sops-nix.nixosModules.sops
    nixos-cli.nixosModules.nixos-cli
    home-manager.nixosModules.home-manager
    nix-private.nixosModules.private
  ];
  services.nixos-cli = { enable = true; };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.nmclarty = "${inputs.self}/home.nix";
  };
  private.enable = true;
}
