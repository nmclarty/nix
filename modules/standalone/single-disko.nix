{
  disko.devices = {
    disk = {
      primary = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
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
      zroot = {
        type = "zpool";
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "lz4";
          xattr = "sa";
        };
        mountpoint = "none";
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
          "zroot/nixos/cache" = {
            type = "zfs_fs";
            mountpoint = "/var/cache";
          };
          "zroot/nixos/containers" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/containers";
          };
        };
      };
    };
  };
}
