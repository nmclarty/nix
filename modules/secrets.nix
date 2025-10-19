{ config, inputs, ... }: {
  sops = {
    defaultSopsFile =
      "${inputs.nix-private}/${config.networking.hostName}/secrets.yaml";
    log = [ "secretChanges" ];
    age = {
      generateKey = true;
      sshKeyPaths = [ "/root/.ssh/id_ed25519" ];
      keyFile = "/var/lib/sops-nix/key.txt";
    };
    # global secrets (that can be used by system and home-manager)
    secrets = {
      "nmclarty/ssh/remote" = {
        sopsFile = "${inputs.nix-private}/secrets.yaml";
        owner = "nmclarty";
      };
      "nmclarty/ssh/public" = {
        sopsFile = "${inputs.nix-private}/secrets.yaml";
        path = "/home/nmclarty/.ssh/id_ed25519.pub";
        owner = "nmclarty";
      };
      "nmclarty/ssh/private" = {
        sopsFile = "${inputs.nix-private}/secrets.yaml";
        path = "/home/nmclarty/.ssh/id_ed25519";
        owner = "nmclarty";
      };
    };
    templates = {
      "git/allowed_signers" = {
        owner = "nmclarty";
        content = ''
          ${config.private.git.email} namespaces="git" ${config.sops.placeholder."nmclarty/ssh/remote"}
        '';
      };
    };
  };
}
