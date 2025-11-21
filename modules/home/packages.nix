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
      # fish
      lolcat
      xxd
      # dev tools
      gh
      docker-client
      shellcheck
      # dev languages
      python3
      nodejs
      go
    ];
  };
}
