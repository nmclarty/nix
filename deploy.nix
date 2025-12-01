{ inputs }:
let
  inherit (inputs) deploy-rs self;
in
{
  # create deploy-rs nodes for each NixOS configuration
  deploy = {
    sshUser = "root";
    user = "root";
    nodes = builtins.mapAttrs
      (name: value: {
        hostname = name;
        profiles.system = {
          remoteBuild = value.pkgs.stdenv.system != "x86_64-linux";
          path = deploy-rs.lib.${value.pkgs.stdenv.system}.activate.nixos self.nixosConfigurations.${name};
        };
      })
      self.nixosConfigurations;
  };
}
