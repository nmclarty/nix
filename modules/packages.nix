{ pkgs-unstable, ... }: {
  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # packages
  # environment.systemPackages = with pkgs; [ ];

  # programs
  programs = {
    fish.enable = true;
    # to fix vscode remote development
    nix-ld.enable = true;
    # command-not-found doesn't work with flakes
    command-not-found.enable = false;
  };

  # services
  systemd.services.tailscaled.serviceConfig.LogLevelMax = "notice";
  services = {
    # clean up lingering apps on ssh session loss
    logind.killUserProcesses = true;
    # remote access
    tailscale = {
      enable = true;
      openFirewall = true;
      package = pkgs-unstable.tailscale;
      useRoutingFeatures = "server";
    };
    sanoid = {
      enable = true;
      templates.default = {
        hourly = 24;
        daily = 7;
        monthly = 0;
        yearly = 0;
        autosnap = true;
        autoprune = true;
      };
      datasets.zroot = {
        useTemplate = [ "default" ];
        recursive = true;
        processChildrenOnly = true;
      };
    };
  };

  # sudo
  security.sudo.extraConfig = ''
    Defaults env_keep += "EDITOR"
  '';
}
