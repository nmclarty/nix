{ inputs, config, pkgs, ... }: {
  imports = [ inputs.comin.nixosModules.comin ];
  sops.secrets."github/token".sopsFile = "${inputs.nix-private}/secrets.yaml";
  services.comin = {
    enable = true;
    remotes = [
      {
        name = "github";
        url = "https://github.com/nmclarty/nix.git";
        branches.main.name = "main";
        auth.access_token_path = config.sops.secrets."github/token".path;
      }
      {
        name = "local";
        url = "/home/nmclarty/projects/nix";
        branches.main.name = "main";
        poller.period = 2;
      }
    ];
    postDeploymentCommand = pkgs.writers.writeBash "post" ''
      env | grep COMIN_ > /var/lib/comin/deployment.status
    '';
  };
}
