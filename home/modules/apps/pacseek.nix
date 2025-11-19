{ pkgs, lib }:

pkgs.buildGoModule rec {
  pname = "pacseek";
  version = "1.8.5";

  src = pkgs.fetchFromGitHub {
    owner = "moson-mo";
    repo  = "pacseek";
    rev   = "v${version}";

    # TEMPORARY dummy hash – we'll replace after Nix tells us the real one
    hash  = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  # TEMPORARY dummy vendor hash – also replaced after first build
  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "A terminal UI for searching and installing Arch Linux and AUR packages";
    homepage    = "https://github.com/moson-mo/pacseek";
    license     = licenses.mit;
    platforms   = platforms.linux;
  };
}
