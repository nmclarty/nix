{
  description = "A NixOS flake for managing my homelab.";
  inputs = {
    # nixos
    stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # extras
    quadlet-nix.url = "github:seiarotg/quadlet-nix";
    sops-nix.url = "github:Mic92/sops-nix";
    nixos-cli.url = "github:nix-community/nixos-cli";
    # private
    nix-private = {
      url = "git+ssh://git@github.com/nmclarty/nix-private";
      inputs.nixpkgs.follows = "stable";
    };
    nix-secrets = {
      url = "git+ssh://git@github.com/nmclarty/nix-secrets";
      flake = false;
    };
  };

  outputs = inputs: {
    nixosConfigurations = {
      brittlehollow = inputs.stable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs system;
          pkgs-unstable = import inputs.unstable { inherit system; };
        };
        modules = [ ./modules ./servers/brittlehollow ];
      };

      timberhearth = inputs.stable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs system;
          pkgs-unstable = import inputs.unstable { inherit system; };
        };
        modules = [ ./modules ./servers/timberhearth ];
      };
    };
  };
}
