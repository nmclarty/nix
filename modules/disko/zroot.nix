{
  disko.devices = {
    zpool = {
      zroot = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "lz4";
          xattr = "sa";
          mountpoint = "none";
        };
        datasets = {
          # persistent datasets (will be backed up)
          nixos = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          srv = {
            type = "zfs_fs";
            mountpoint = "/srv";
          };
          # non-persistent datasets
          "nixos/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          "nixos/cache" = {
            type = "zfs_fs";
            mountpoint = "/var/cache";
          };
          "nixos/containers" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/containers";
          };
        };
      };
    };
  };
}
