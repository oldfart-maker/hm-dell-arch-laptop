{ pkgs, lib }:

pkgs.buildGoModule rec {
  pname = "pacseek";
  version = "1.8.5";

  src = pkgs.fetchFromGitHub {
    owner  = "moson-mo";
    repo   = "pacseek";
    rev    = "v${version}";
    sha256 = lib.fakeSha256;  # placeholder – we’ll fill the real hash in next step
  };

  # Go modules hash – also start with a fake and let Nix tell us the real one
  vendorHash = lib.fakeSha256;

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "A terminal UI for searching and installing Arch Linux and AUR packages";
    homepage    = "https://github.com/moson-mo/pacseek";
    license     = licenses.mit;
    platforms   = platforms.linux;
  };
}
