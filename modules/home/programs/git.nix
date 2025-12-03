{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Nevan McLarty";
        email = "37232202+nmclarty@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      gpg.ssh.defaultKeyCommand = "ssh-add -L";
    };
    signing = {
      format = "ssh";
      signByDefault = true;
    };
  };
}
