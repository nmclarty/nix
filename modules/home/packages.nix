{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      # shell
      fd
      zoxide
      bat
      ripgrep
      tldr
      # utilities
      gdu
      wget
      doggo
      moreutils
      yq-go
      zstd
      goaccess
      iperf
      # backups
      resticprofile
      # secrets
      sops
      pwgen
      ssh-to-age
    ];
  };
}
