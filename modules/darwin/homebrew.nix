{
  homebrew = {
    enable = true;
    global.autoUpdate = false;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
      extraFlags = [ "--quiet" ];
    };
    caskArgs = {
      appdir = "/Applications/homebrew";
    };
    brews = [
      # mas cli for searching for mac app store apps
      "mas"
      # colima requires the docker cli, otherwise it won't start
      # however, we're not going to use it (instead from home manager)
      "docker"
      # install colima and automatically start/restart it
      { name = "colima"; restart_service = true; }
    ];
    masApps = {
      Xcode = 497799835;
      Infuse = 1136220934;
      "Wifi Explorer" = 494803304;
      "Windows App" = 1295203466;
      "Microsoft Word" = 462054704;
    };
    casks = [
      # utilities
      "1password"
      "seafile-client"
      "tailscale-app"
      "scroll-reverser"
      # tools
      "stats"
      "balenaetcher"
      # development
      "visual-studio-code"
      "wireshark-app"
      "jetbrains-toolbox"
      "claude-code"
      # media
      "google-chrome"
      "spotify"
      "zen"
      "discord"
      "prismlauncher"
      "blender"
    ];
  };
}
