{ pkgs, config, inputs, ... }: {
  # version
  system.stateVersion = "25.05";

  # locale
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  services.xserver.xkb.layout = "us";

  # swap
  zramSwap.enable = true;

  # nix settings
  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  # disable generating man cache (because fish causes it to hang)
  documentation.man.generateCaches = false;

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

  # users
  sops.secrets = {
    "nmclarty/hashedPassword" = {
      sopsFile = "${inputs.nix-private}/secrets.yaml";
      neededForUsers = true;
    };
    "root/hashedPassword" = {
      sopsFile = "${inputs.nix-private}/secrets.yaml";
      neededForUsers = true;
    };
  };
  users = {
    mutableUsers = false;
    users.root = {
      shell = pkgs.fish;
      hashedPasswordFile = config.sops.secrets."root/hashedPassword".path;
    };
    users.nmclarty = {
      isNormalUser = true;
      extraGroups = [ "wheel" "systemd-journal" ];
      shell = pkgs.fish;
      uid = 1000;
      hashedPasswordFile = config.sops.secrets."nmclarty/hashedPassword".path;
    };
  };
}
