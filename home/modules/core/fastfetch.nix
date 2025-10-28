{ config, pkgs, repoPath, lib, ... }:

let
  cfgPath  = repoPath "home/data/apps/fastfetch/config.jsonc";
  logoPath = repoPath "home/data/apps/fastfetch/logo";
in
{
  home.packages = [ pkgs.fastfetch ];

  xdg.configFile."fastfetch/config.jsonc" = {
    source = cfgPath;       # ← store-managed
    force  = true;
  };

  xdg.configFile."fastfetch/logo" = lib.mkIf (builtins.pathExists logoPath) 
    source    = logoPath;   # directory or file; OK either way
    recursive = true;
    force     = true;
  };

  home.activation.fastfetchCheck = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "${cfgPath}" ]; then
      echo "[fastfetch] ERROR: ${cfgPath} missing."
      echo "[fastfetch] Copy your config into home/dotfiles/fastfetch/ then hm-update."
      exit 42
    fi
  '';
}
