{ inputs, ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks =
      let
        # get all the hosts
        hosts = builtins.attrNames inputs.self.nixosConfigurations;
        # generate configuration for each that allows agent forwarding
        generatedBlocks = builtins.listToAttrs (
          map
            (host: {
              name = host;
              value = {
                forwardAgent = true;
              };
            })
            hosts
        );
        # add manual config for hosts that aren't managed by nix
        manualBlocks = {
          "github.com" = {
            hostname = "ssh.github.com";
            port = 443;
          };
        };
      in
      # combine both and set the config option
      generatedBlocks // manualBlocks;
  };
}
