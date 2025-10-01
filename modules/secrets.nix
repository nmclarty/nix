{ config, inputs, ... }: {
  sops = {
    defaultSopsFile =
      "${inputs.nix-secrets}/${config.networking.hostName}/secrets.yaml";
    log = [ "secretChanges" ];
    age = {
      generateKey = true;
      sshKeyPaths = [ "/root/.ssh/id_ed25519" ];
      keyFile = "/var/lib/sops-nix/key.txt";
    };
  };
}
