{ inputs, config, pkgs, ... }: {
  imports = [ inputs.comin.nixosModules.comin ];
  # secret for pulling private repos
  sops.secrets."github/token".sopsFile = "${inputs.nix-private}/secrets.yaml";
  # add jq to path for outputting the status in JSON
  systemd.services.comin.path = [ pkgs.jq ];
  services.comin = {
    enable = true;
    remotes = [
      {
        name = "github";
        url = "https://github.com/nmclarty/nix.git";
        branches.main.name = "main";
        auth.access_token_path = config.sops.secrets."github/token".path;
      }
    ];
    postDeploymentCommand = pkgs.writers.writeBash "post" ''
      jq -n 'env | to_entries | map(select(.key | startswith("COMIN"))) | from_entries' > /var/lib/comin/status.json
    '';
  };
}
