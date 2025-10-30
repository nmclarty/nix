{ inputs, flake, ... }: {
  imports = with inputs; [
    home-manager.darwinModules.home-manager
    nix-private.darwinModules.private
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    users.nmclarty = "${flake}/modules/home";
    extraSpecialArgs = { inherit inputs; };
  };
  private.enable = true;
}
