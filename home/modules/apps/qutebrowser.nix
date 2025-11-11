{ pkgs, ... }:

let
  quteWrapped = pkgs.writeShellScriptBin "qutebrowser" ''
    # Force Qt to use Wayland, not X11
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

    # Run the Nix qutebrowser through nixGL so it sees the host GPU drivers
    exec nixGL ${pkgs.qutebrowser}/bin/qutebrowser "$@"
  '';

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

    # Optional keybindings
    keyBindings = {
      normal = {
        "d" = "scroll-page 0 0.5";   # scroll down half page
        "u" = "scroll-page 0 -0.5";  # scroll up half page
        "J" = "tab-next";
        "K" = "tab-prev";
        "x" = "tab-close";
        "X" = "undo";
      };
    };
  };
}
