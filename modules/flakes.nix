{inputs,system, ...}: {
  imports = with inputs; [ 
    quadlet-nix.nixosModules.quadlet 
    sops-nix.nixosModules.sops
    nixos-cli.nixosModules.nixos-cli
    nix-private.nixosModules.private
  ];
  services.nixos-cli = {
    enable = true;
  };
  private.enable = true;
}
