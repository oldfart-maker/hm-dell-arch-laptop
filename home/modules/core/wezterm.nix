{ config, pkgs, repoPath, lib, ... }:

let
  cfgPath  = repoPath "home/data/apps/wezterm/wezterm.lua";
  colorsPath = repoPath "home/data/apps/wezterm/colors";
in
{
  home.packages = [ pkgs.wezterm ];

  xdg.configFile."wezterm/wezterm.lua" = {
    source = cfgPath;
    force  = true;
  };

  xdg.configFile."wezterm/colors" = lib.mkIf (builtins.pathExists colorsPath) {
    source    = colorsPath;
    recursive = true;
    force     = true;
  };
}
