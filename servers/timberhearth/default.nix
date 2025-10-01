{
  imports = [
    ../hardware.nix
    ];
  # Network
  networking = {
    hostName = "timberhearth";
    hostId = "41bc3559";
    useNetworkd = true;
    vlans = {
      servers = { id = 4;  interface = "enp1s0"; };
    };
    interfaces = {
      enp1s0.useDHCP = false;
      servers.useDHCP = true;
    };
  };
}
