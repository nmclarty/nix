{ inputs, ...}: {
  imports = with inputs; [
    home-manager.darwinModules.home-manager
    nix-private.darwinModules.private
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    users.nmclarty = "${inputs.self}/home";
    extraSpecialArgs = { inherit inputs; };
  };
  private.enable = true;
}
