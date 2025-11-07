{
  description = "A NixOS flake for managing my computers.";
  inputs = {
    # system
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    # utilities
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
    nix-private.url = "github:nmclarty/nix-private";
    nix-private.inputs.nixpkgs.follows = "nixpkgs";
    # extras
    quadlet-nix.url = "github:seiarotg/quadlet-nix";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.2";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    comin.url = "github:nlewo/comin";
    comin.inputs.nixpkgs.follows = "nixpkgs";
  };
  # Load the blueprint
  outputs = inputs:
    inputs.blueprint {
      inherit inputs;
    };
}
