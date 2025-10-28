# home/modules/tools.nix
{ config, repoPath, ... }:
{
  # Ensure ~/.local/bin exists and script is linked, executable
  home.file.".local/bin/hm-update" = {
    source = repoPath "home/scripts/hm-update.sh";
    executable = true;
  };
}
