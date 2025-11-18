{
  # tailscale needs networkd for dns to work properly
  networking.useNetworkd = true;
  systemd.services.tailscaled = {
    # since tailscale ssh is killed during switch
    # disable automatic restarts, and manage updates manually
    restartIfChanged = false;
    serviceConfig.LogLevelMax = "notice";
  };
  services = {
    # clean up lingering apps on ssh session loss
    logind.settings.Login.KillUserProcesses = true;
    # remote access
    tailscale = {
      enable = true;
      openFirewall = true;
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
    iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };
}
