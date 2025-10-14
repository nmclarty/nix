{ inputs, config, ... }: {
  imports = [ ./containers ../hardware.nix ./ups.nix ];
  # Network
  networking = {
    hostName = "brittlehollow";
    hostId = "012580f6";
    useNetworkd = true;
  };
  sops.secrets."zfs/tank".sopsFile =
    "${inputs.nix-secrets}/${config.networking.hostName}/secrets.yaml";
  # ZFS
  boot.zfs.extraPools = [ "tank" ];
  # Private
  private.containers.enable = true;
}
