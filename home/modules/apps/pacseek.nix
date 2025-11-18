{ pkgs, lib, ... }:

pkgs.buildGoModule rec {
  pname = "pacseek";
  version = "2.2.0";

  # Source from GitHub
  src = pkgs.fetchFromGitHub {
    owner = "mstksg";
    repo = "pacseek";
    rev = "v${version}";
    sha256 = "sha256-PN8m0dFIfHqQ4k75zK0hPmzc0o7ZKq8K8Wr+o0jVZBU=";
  };

  # Go modules vendor hash (must be correct!)
  vendorHash = "sha256-3eYj6tdN7HQK0fV4kYZaIZX7oc1xpm/OuYfN6NsJAu8=";

  # Build flags if needed
  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "TUI search engine for pacman/AUR packages";
    homepage = "https://github.com/mstksg/pacseek";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.linux;
  };
}
