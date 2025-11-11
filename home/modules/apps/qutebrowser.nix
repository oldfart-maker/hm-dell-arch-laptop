{ pkgs, ... }:

{  
  programs.qutebrowser = {
    enable = true;

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
