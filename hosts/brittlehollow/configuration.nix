{ inputs, config, flake, ... }: {
  imports = [
    flake.modules.nixos.default
    flake.modules.server.default
    ./containers
    ./ups.nix
    ./lanzaboote.nix
  ];
  # set arch
  nixpkgs.hostPlatform = "x86_64-linux";
  # Network
  networking = {
    hostName = "brittlehollow";
    hostId = "012580f6";
    useNetworkd = true;
  };
  sops.secrets."zfs/tank".sopsFile =
    "${inputs.nix-private}/${config.networking.hostName}/secrets.yaml";
  # ZFS
  boot.zfs.extraPools = [ "tank" ];
  services.sanoid.datasets.tank = {
    useTemplate = [ "default" ];
    recursive = true;
  };
  # Private
  private.containers.enable = true;
}
