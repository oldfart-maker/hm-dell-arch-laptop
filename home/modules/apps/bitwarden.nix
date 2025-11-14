{ pkgs, ... }:

let
  _Wrapped = pkgs.writeShellScriptBin "bitwarden" ''
    # Force Qt to use Wayland, not X11
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

    # Run through nixGL so it sees the host GPU drivers
    exec nixGL ${pkgs.bitwarden}/bin/bitwarden "$@"
  '';

in {  
  programs.bitwarden = {
    enable = true;
    package=_Wrapped
  };
}
