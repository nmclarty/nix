{
  imports = [ ./single-disko.nix ];
  disko.devices = {
    disk = {
      secondary = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot.mode = "mirror";
    };
  };
}
