{ config, ... }: {
  # sysctls
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "vm.overcommit_memory" = 1; # allow overcommit for redis
  };
  # pam
  security.pam = {
    sshAgentAuth = {
      enable = true;
      authorizedKeysFiles = [ config.sops.secrets."nmclarty/ssh/remote".path ];
    };
    services.sudo.sshAgentAuth = true;
  };
  # use systemd boot
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      configurationLimit = 5;
      enable = true;
    };
  };
}
