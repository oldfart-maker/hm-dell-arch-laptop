{ config, pkgs, lib, ... }:
{
  home.username = "username";
  home.homeDirectory = "/home/username";
  home.stateVersion = "24.05";

  # keep git installed via HM from now on
  home.packages = with pkgs; [ git ];

  imports = [
    ./modules/bin/paths.nix
    
    ./modules/core/user-dirs.nix    
    ./modules/core/system-theme.nix
    ./modules/core/fonts.nix
    ./modules/core/fonts-extra.nix
    ./modules/core/foot.nix    
    ./modules/core/fish.nix
    ./modules/core/fastfetch.nix
    ./modules/core/wallpaper.nix
    ./modules/core/dev-tools.nix    
    ./modules/tools/tools.nix

    ./modules/apps/make/mako.nix
    ./modules/apps/emacs.nix
    
    ./modules/wm/niri/niri.nix
    ./modules/wm/niri/niri-data.nix
    ./modules/wm/niri/waybar.nix
    ./modules/wm/niri/rofi.nix

    ./modules/wm/sway/sway.nix
  ];

  programs.home-manager.enable = true;  
}
