{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      # general
      eza
      # utilities
      gdu
      micro
      wget
      doggo
      moreutils
      yq-go
      difftastic
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
