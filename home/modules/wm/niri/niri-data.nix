# home/modules/niri-data.nix
{ config, lib, repoPath, ... }:

let
  # Paths in your repo
  niriRoot   = repoPath "home/data/apps/niri;
  scriptsDir = niriRoot + "/scripts";
  rofiDir    = niriRoot + "/rofi";

  linkDir = src: target: {
    ${target} = {
      source    = src;
      recursive = true;
      force     = true;
    };
  };
in
{
  home.file =
    lib.mkMerge [
      (lib.optionalAttrs (builtins.pathExists scriptsDir)
        (linkDir scriptsDir ".config/niri/scripts"))

      (lib.optionalAttrs (builtins.pathExists rofiDir)
        (linkDir rofiDir ".config/niri/rofi"))
    ];
}
