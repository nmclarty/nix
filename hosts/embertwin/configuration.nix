{ flake, ... }: {
  imports = [
    flake.modules.nixos.default
    flake.modules.server.default
  ];
  # Network
  networking = {
    hostName = "embertwin";
    hostId = "c8cdbbba";
    useNetworkd = true;
  };
}
