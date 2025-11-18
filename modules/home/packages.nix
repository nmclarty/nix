{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      # shell
      eza
      fd
      zoxide
      bat
      ripgrep
      tldr
      # utilities
      gdu
      micro
      wget
      doggo
      moreutils
      yq-go
      zstd
      lazygit
      goaccess
      iperf
      ssh-to-age
      # nixos
      nh
      nixd
      statix
      nixpkgs-fmt
      # backups
      resticprofile
      # secrets
      sops
      pwgen
      # prompt
      lolcat
      # development
      python3
      nodejs
      go
    ];
  };
}
