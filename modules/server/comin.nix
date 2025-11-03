{inputs, config, ...}: {
  imports = [ inputs.comin.nixosModules.comin ];
  sops.secrets."github/token".sopsFile = "${inputs.nix-private}/secrets.yaml";
  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/nmclarty/nix.git";
        branches.main.name = "main";
        auth.access_token_path = config.sops.secrets."github/token".path;
      }
    ];
  };
}
