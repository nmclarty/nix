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
      # nixos
      nh
      nixd
      nixpkgs-fmt
      # backups
      resticprofile
      # secrets
      sops
      pwgen
    ];
  };
}
