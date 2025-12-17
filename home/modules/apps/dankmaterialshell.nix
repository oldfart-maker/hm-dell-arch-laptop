{ pkgs, repoPath, config, lib, ... }:

let
  # Upstream installer archive (gzipped)
  dankInstallUrl =
    "https://github.com/AvengeMedia/DankMaterialShell/releases/download/v0.5.1/dankinstall-amd64.gz";

  # Use the sha256 published by the project (or from nix-prefetch-url)
  # Example placeholder:
  dankInstallSha256 = "sha256:e017b2b0df7b720bf12661bbdbaba44eac61d7c09797a671f40c4f619ec59ae9";

  cfgDir  = "${config.xdg.configHome}/DankMaterialShell";
  seedFile  = repoPath "home/data/apps/dankmaterialshell/settings.json";
  
in
{
  home.packages = [
    (pkgs.runCommand "dankmaterialshell" { buildInputs = [ pkgs.gzip ]; } ''
      mkdir -p $out/bin

      # Download the gzipped installer/binary
      installer_gz=${pkgs.fetchurl {
        url = dankInstallUrl;
        sha256 = dankInstallSha256;
      }}

      # Decompress into $out/bin/dankmaterialshell-installer (or binary)
      gzip -c -d "$installer_gz" > $out/bin/dankmaterialshell-installer

      chmod +x $out/bin/dankmaterialshell-installer

      # Create a user-facing wrapper called `dankmaterialshell`
      cat > $out/bin/dankmaterialshell << 'EOF'
      #!/usr/bin/env bash
      exec "$(dirname "$0")/dankmaterialshell-installer" "$@"
      EOF

      chmod +x $out/bin/dankmaterialshell
    '')
  ];

  home.activation.seedDankMaterialShellSettings =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    mkdir -p "${cfgDir}"
    if [ ! -s "${cfgDir}/settings.json" ]; then
       cp -f "${seedFile}" "${cfgDir}/settings.json"
       chmod u+rw "${cfgDir}/settings.json"
    fi
   '';
  }
