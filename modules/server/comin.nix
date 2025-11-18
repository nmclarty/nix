{ inputs, config, ... }: {
  imports = [ inputs.comin.nixosModules.comin ];
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
  };
}
