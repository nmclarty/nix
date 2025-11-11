{ config, pkgs, ... }: {
  sops.secrets = {
    "restic/password" = { };
    "restic/local/access" = { };
    "restic/local/secret" = { };
    "restic/remote/access" = { };
    "restic/remote/secret" = { };
  };
  sops.templates."restic/profiles.toml" = {
    path = "/etc/resticprofile/profiles.toml";
    content = ''
      version = "1"
      [template]
        force-inactive-lock = true
        initialize = true
        cache-dir = "/var/cache/restic"
        cleanup-cache = true
        extended-status = true
        pack-size = 64
        password-file = "${config.sops.secrets."restic/password".path}"
        [template.backup]
          tag = "automatic"
          source = [ "nixos", "srv" ]
          source-base = "/.backup"
          source-relative = true
        [template.retention]
          after-backup = true
          tag = true
          prune = true
          keep-daily = 7
          keep-weekly = 4

      [local]
        inherit = "template"
        repository = "s3:${config.private.restic.local.host}/${config.networking.hostName}-restic"
        status-file = "/var/lib/resticprofile/local.status"
      [local.env]
        AWS_ACCESS_KEY_ID = "${config.sops.placeholder."restic/local/access"}"
        AWS_SECRET_ACCESS_KEY = "${
          config.sops.placeholder."restic/local/secret"
        }"

      [remote]
        inherit = "template"
        repository = "s3:${config.private.restic.remote.host}/${config.networking.hostName}-restic"
        status-file = "/var/lib/resticprofile/remote.status"
      [remote.env]
        AWS_ACCESS_KEY_ID = "${config.sops.placeholder."restic/remote/access"}"
        AWS_SECRET_ACCESS_KEY = "${
          config.sops.placeholder."restic/remote/secret"
        }"
    '';
  };
  systemd.services.backup = {
    description = "Snapshot disks and backup using restic";
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    path = with pkgs; [
      systemd
      coreutils
      moreutils
      util-linux
      zfs
      resticprofile
      podman
      jq
    ];
    serviceConfig.AllowedCPUs = "12-19";
    script = ''
      function cleanup {
        echo "Unmounting snapshots in '/.backup'..."
        parallel -i umount {} -- $(mount -t zfs | cut -d " " -f 3 | grep ^/.backup | xargs)
        echo "Destroying snapshots of $1..."
        parallel -i -j 1 zfs destroy {} -- $(zfs list -H -d 2 -o name -t snapshot $1 | grep @backup | xargs)
      }
      function snapshot {
        volumes=$(zfs list -H -d 1 -o name $1 | grep /)
        echo "Snapshotting volumes in $1..."
        parallel -i zfs snapshot {}@backup -- $(xargs <<< "$volumes")
        echo "Mounting snapshots in '/.backup'..."
        parallel -i mount -m -t zfs $1/{}@backup /.backup/{} -- $(cut -d "/" -f 2 <<< "$volumes")
      }
      function createDirs {
        mkdir -p /.backup
        mkdir -p /var/lib/resticprofile
      }
      function getRunningContainers {
        podman quadlet list --format json | \
          jq -r "map(select((.Name | contains(\".container\")) and .Status == \"active/running\")) | .[].UnitName"
      }

      set -euo pipefail

      # make sure directories exist
      createDirs
      
      # get the list of running quadlet containers
      containers=$(getRunningContainers)

      # stop containers if there are any
      if [[ -n "$containers" ]]; then
        systemctl stop $containers
      fi

      # unmount and delete any leftover snapshots
      cleanup zroot

      # create new snapshots and mount them
      snapshot zroot

      # start containers if there are any
      if [[ -n "$containers" ]]; then
        systemctl start $containers
      fi

      # run the backups in parallel
      parallel -i resticprofile {}.backup -- local remote

      # unmount and delete snapshots
      cleanup zroot
    '';
  };
  systemd.timers.backup = {
    enable = true;
    description = "Run backup daily at 4am";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 4:00:00";
      Persistent = true;
    };
  };
}
