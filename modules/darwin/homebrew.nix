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
      "mas"
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
