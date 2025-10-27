{
  homebrew = {
  	enable = true;
  	global.autoUpdate = false;
  	onActivation = {
  	  cleanup = "zap";
  	  upgrade = true;
  	};
  	caskArgs = {
  	  appdir = "/Applications/homebrew";
  	  require_sha = true;
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
      "stats"
  	  # development
  	  "docker-desktop"
  	  "visual-studio-code"
  	  "wireshark-app"
  	  "alacritty"
  	  # media
  	  "firefox"
  	  "zen"
  	  "discord"
  	  "prismlauncher"
  	  "blender"
  	];
  };
}
