{ flake, ...}: {
  imports = [ 
    flake.modules.nixos.default
    flake.modules.server.default
  ];
  # Network
  networking = {
    hostName = "timberhearth";
    hostId = "41bc3559";
    useNetworkd = true;
  };
}
