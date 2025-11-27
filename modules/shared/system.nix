{flake, config, ...}:
let
  # short git rev for the version label (i.e. "6669da0" or "6669da0-dirty")
  shortRev = flake.shortRev or flake.dirtyShortRev or "unknown";
  # nixos date from the version suffix (i.e. "20251122")
  nixDate = builtins.substring 1 8 (config.system.nixos.versionSuffix);
in
{
  system = { 
    # the full git ref that the system was built from
    configurationRevision = flake.rev or flake.dirtyRev or "unknown";
    # the label combining the nixos release and date, and with git ref of the flake commit
    nixos.label = with config.system.nixos; release + "-" + nixDate + ":git-" + shortRev;
  };
}
