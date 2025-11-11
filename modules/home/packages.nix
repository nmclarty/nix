{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      # general utilities
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
    ];
  };
}
