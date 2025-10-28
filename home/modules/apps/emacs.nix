# home/modules/apps/emacs/default.nix
{ self, config, pkgs, lib, ... }:

let
  # Choose an Emacs build available on this nixpkgs
  emacsPkg = (pkgs.emacs30-pgtk or pkgs.emacs29-pgtk or pkgs.emacs-gtk or pkgs.emacs);

  # Repo-root anchored sources (committed under home/data/apps/emacs)
  emacsSrcDir = self + "/home/data/apps/emacs";
  srcEarly    = emacsSrcDir + "/early-init.el";   # optional
  srcInit     = emacsSrcDir + "/init.el";
  srcModules  = emacsSrcDir + "/modules";         # dir with *.el

  # Install target in $HOME
  emacsDir = "${config.xdg.configHome}/emacs-prod";
in
{
  home.packages = [ emacsPkg ];

  # Fail early if required files are missing in the repo
  assertions = [
    { assertion = builtins.pathExists srcInit;
      message   = "[emacs] Missing ${srcInit}. Put your init.el under home/data/apps/emacs/"; }
    { assertion = builtins.pathExists srcModules;
      message   = "[emacs] Missing ${srcModules} directory under home/data/apps/emacs/"; }
  ];

  # Copy committed config into ~/.config/emacs-prod (reproducible)
  home.file."${emacsDir}/early-init.el".source    = srcEarly;
  home.file."${emacsDir}/init.el".source          = srcInit;

  home.file."${emacsDir}/modules" = {
    source    = srcModules;
    recursive = true;
  };
  
  # Emacs daemon using that init directory
  systemd.user.services.emacs-prod = {
    Unit = {
      Description = "Emacs daemon (emacs-prod)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${emacsPkg}/bin/emacs --fg-daemon=emacs-prod --init-directory=%h/.config/emacs-prod";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
