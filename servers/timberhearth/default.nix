{
  imports = [ ../hardware.nix ];
  # Network
  networking = {
    hostName = "timberhearth";
    hostId = "41bc3559";
    useNetworkd = true;
  };
}
