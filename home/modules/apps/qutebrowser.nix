{ pkgs, ... }:

let
  quteWrapped = pkgs.writeShellScriptBin "qutebrowser" ''
    # Force Qt to use Wayland, not X11
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

    # Run the Nix qutebrowser through nixGL so it sees the host GPU drivers
    exec nixGL ${pkgs.qutebrowser}/bin/qutebrowser "$@"
  '';

  cfgPath  = repoPath "home/data/apps/qutebrwoser/config.py";
  themePath = repoPath "home/data/apps/qutebrowser/gruvbox.py";
  
in {  
  programs.qutebrowser = {
    enable = true;

    package=quteWrapped;
    
    settings = {
      # Default zoom level
      zoom.default = "110%";

      # Block ads/tracking (requires qtwebengine compiled with adblock)
      content.blocking.enabled = true;

      # Dark mode if desired
      colors.webpage.darkmode.enabled = true;

      # Load last session automatically
      auto_save.session = true;
      session.default_name = "default";

      # Downloads
      downloads.location.directory = "~/Downloads";
    };
  };

  home.file = {
    ".config/qutebrowser/config.py" = {
      force  = true;
      source = cfgPath;
    };
  }

  home.file = {
    ".config/qutebrowser/gruvbox.py" = {
      force  = true;
      source = themePath;
    };
  }

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
