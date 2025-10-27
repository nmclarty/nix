{
  description = "A NixOS flake for managing my homelab.";
  inputs = {
    # system
    stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "stable";
    # home-manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "stable";
    # extras
    quadlet-nix.url = "github:seiarotg/quadlet-nix";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "stable";
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.2";
    lanzaboote.inputs.nixpkgs.follows = "stable";
    # private
    nix-private.url = "git+ssh://git@github.com/nmclarty/nix-private";
    nix-private.inputs.nixpkgs.follows = "stable";
  };

  outputs = inputs: {
    nixosConfigurations = {
      brittlehollow = inputs.stable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import inputs.unstable { inherit system; };
        };
        modules = [ ./modules ./servers/brittlehollow ];
      };

      timberhearth = inputs.stable.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import inputs.unstable { inherit system; };
        };
        modules = [ ./modules ./servers/timberhearth ];
      };
    };

    darwinConfigurations = {
      nevan-macbook = inputs.darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./darwin/nevan-macbook ];
      };
    };
  };
}
