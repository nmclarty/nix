{ pkgs, inputs, ... }: {
  # import flake modules
  imports = with inputs; [
    nixos-cli.nixosModules.nixos-cla
  ];

  # allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # programs
  programs = {
    # fish is mainly configured in home manager
    fish.enable = true;
    # to fix vscode remote development
    nix-ld.enable = true;
    # command-not-found doesn't work with flakes
    command-not-found.enable = false;
  };

  # nixos-cli settings
  environment.systemPackages = with pkgs; [
    nvd
    nix-output-monitor
  ];
  services.nixos-cli = {
    enable = true;
    config = {
      use_nvd = true;
      apply = {
        use_git_commit_msg = true;
        use_nom = true;
      };
    };
  };

  # disable generating man cache (because fish causes it to hang)
  documentation.man.generateCaches = false;

  # security
  security = {
    sudo.extraConfig = ''Defaults env_keep += "EDITOR"'';
    wrappers.btop = {
      enable = true;
      owner = "root";
      group = "root";
      source = "${pkgs.btop}/bin/btop";
      capabilities = "cap_perfmon=ep";
    };
  };
}
