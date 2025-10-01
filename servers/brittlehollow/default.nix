{inputs, config, ...}: {
  imports = [
    ../hardware.nix
    ./ups.nix
    ./containers
    ];
  # Network
  networking = {
    hostName = "brittlehollow";
    hostId = "012580f6";
    useNetworkd = true;
    vlans = {
      servers = { id = 4;  interface = "enp4s0"; };
    };
    interfaces = {
      enp4s0.useDHCP = false;
      servers.useDHCP = true;
    };
  };
  sops.secrets."zfs/tank".sopsFile = "${inputs.nix-secrets}/${config.networking.hostName}/secrets.yaml";
  # ZFS
  boot.zfs.extraPools = [ "tank" ];
}
