{ pkgs }:
pkgs.mkShell {
  # Add build dependencies
  packages = with pkgs; [
    statix
  ];

  # Add environment variables
  env = { };

  # Load custom bash code
  shellHook = ''

  '';
}
