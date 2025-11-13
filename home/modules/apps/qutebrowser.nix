{ pkgs, repoPath, ... }:

let
  quteWrapped = pkgs.writeShellScriptBin "qutebrowser" ''
    # Force Qt to use Wayland, not X11
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

    # Run the Nix qutebrowser through nixGL so it sees the host GPU drivers
    exec nixGL ${pkgs.qutebrowser}/bin/qutebrowser "$@"
  '';

  cfgPath  = repoPath "home/data/apps/qutebrowser/config.py";
  themePath = repoPath "home/data/apps/qutebrowser/gruvbox.py";
  
in {  
  programs.qutebrowser = {
    enable = true;
    package=quteWrapped;
    extraConfig = builtins.readFile cfgPath;
  };

  home.file.".config/qutebrowser/gruvbox.py".source    = themePath;

 # This is the .desktop entry
  xdg.desktopEntries.qutebrowser-wayland = {
    name = "Qutebrowser (Wayland + nixGL)";
    genericName = "Web Browser";
    comment = "Keyboard-focused browser using Wayland and nixGL";
    exec = "${quteWrapped}/bin/qutebrowser %u";
    icon = "org.qutebrowser.qutebrowser";
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeType = [
      "text/html"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    startupNotify = true;
  };  
}
