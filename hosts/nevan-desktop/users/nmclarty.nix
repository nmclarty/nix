{ flake, lib, config, ... }:
let
  sshPath = "/mnt/c/Windows/System32/OpenSSH";
  signPath = "/mnt/c/Users/${config.home.username}/AppData/Local/Microsoft/WindowsApps";
in
{
  imports = [ flake.modules.home.default ];

  # configure fish and git to use the windows ssh and signing programs
  programs.fish.shellAliases = {
    ssh = "${sshPath}/ssh.exe";
    ssh-add = "${sshPath}/ssh-add.exe";
  };
  programs.git.settings = {
    core.sshCommand = "${sshPath}/ssh.exe";
    gpg.ssh = {
      defaultKeyCommand = lib.mkForce "${sshPath}/ssh-add.exe -L";
      program = "${signPath}/op-ssh-sign-wsl.exe";
    };
  };
}
