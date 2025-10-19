{ pkgs, config, inputs, ... }: {
  # version
  system.stateVersion = "25.05";

  # locale
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_CA.UTF-8";
  services.xserver.xkb.layout = "us";

  # swap
  zramSwap.enable = true;

  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # disable generating man cache (because fish causes it to hang)
  documentation.man.generateCaches = false;

  # sysctls
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "vm.overcommit_memory" = 1; # allow overcommit for redis
  };

  # pam
  sops.secrets."authorized-keys".sopsFile = "${inputs.nix-secrets}/secrets.yaml";
  security.pam = {
    sshAgentAuth = {
      enable = true;
      authorizedKeysFiles = [ config.sops.secrets.authorized-keys.path ];
    };
    services.sudo.sshAgentAuth = true;
  };

  # nixos cleanup
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # users
  sops.secrets = {
    "nmclarty" = {
      sopsFile = "${inputs.nix-secrets}/secrets.yaml";
      neededForUsers = true;
    };
    "root" = {
      sopsFile = "${inputs.nix-secrets}/secrets.yaml";
      neededForUsers = true;
    };
  };
  users = {
    mutableUsers = false;
    users.root = {
      shell = pkgs.fish;
      hashedPasswordFile = config.sops.secrets.root.path;
    };
    users.nmclarty = {
      isNormalUser = true;
      extraGroups = [ "wheel" "systemd-journal" ];
      shell = pkgs.fish;
      packages = with pkgs; [ ];
      uid = 1000;
      hashedPasswordFile = config.sops.secrets.nmclarty.path;
    };
  };
}
