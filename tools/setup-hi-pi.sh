#!/usr/bin/env bash
# Reproduce Pi system with Home Manager (non-NixOS, single-user Nix)
# Implements:
# 0) Install niri (Arch/Manjaro)
# 1) Install Nix (no-daemon) + load env
# 2) Install Home Manager (channel method, as requested)
# 3) Enable nix-command & flakes
# 4) Switch to your Home Manager flake

set -euo pipefail

# --- Config you can tweak ---
HM_USER="${HM_USER:-$USER}"
HM_FLAKE="${HM_FLAKE:-github:oldfart-maker/hm-pi5-arch-pi#${HM_USER}}"
NIX_INSTALL_FLAGS="${NIX_INSTALL_FLAGS:---no-daemon}"

# --- Helpers ---
log() { printf "\n\033[1;32m[+]\033[0m %s\n" "$*"; }
warn(){ printf "\n\033[1;33m[!]\033[0m %s\n" "$*"; }
err() { printf "\n\033[1;31m[x]\033[0m %s\n" "$*"; }

need() {
  command -v "$1" >/dev/null 2>&1 || {
    err "Missing dependency: $1"
    return 1
  }
}

source_nix_env() {
  # shellcheck disable=SC1091
  if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    hash -r || true
  fi
}

# --- Step 0: Install niri (if on an Arch-like with pacman) ---
if command -v pacman >/dev/null 2>&1; then
  log "Step 0: Ensuring niri is installed (pacman)…"
  if ! command -v niri >/dev/null 2>&1; then
    need sudo
    sudo pacman -S --needed --noconfirm niri
  else
    log "niri already present; skipping."
  fi
else
  warn "pacman not found; skipping niri install step."
fi

# --- Step 1: Install Nix (no-daemon) ---
if ! command -v nix >/dev/null 2>&1; then
  log "Step 1: Installing Nix (single-user)…"
  need curl
  sh <(curl -L https://nixos.org/nix/install) "$NIX_INSTALL_FLAGS"
else
  log "Nix already installed; skipping installer."
fi

# Load Nix into current shell
source_nix_env
need nix

# --- Step 2: Install Home Manager (channel method, as provided) ---
log "Step 2: Installing Home Manager via channels…"
if nix-channel --list | grep -q '^home-manager '; then
  log "Home Manager channel already present."
else
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
fi
nix-channel --update

# This creates/updates the 'home-manager' profile entry for your user
if ! command -v home-manager >/dev/null 2>&1; then
  log "Running nix-shell '<home-manager>' -A install…"
  nix-shell '<home-manager>' -A install
else
  log "home-manager command is available; skipping channel install."
fi

# --- Step 3: Enable experimental features (nix-command flakes) ---
log "Step 3: Enabling nix-command & flakes…"
mkdir -p "$HOME/.config/nix"
NIX_CONF="$HOME/.config/nix/nix.conf"
if [ -f "$NIX_CONF" ]; then
  if grep -q '^experimental-features *=.*flakes' "$NIX_CONF"; then
    log "Flakes already enabled in nix.conf."
  else
    warn "Updating existing nix.conf to include experimental-features…"
    cp -a "$NIX_CONF" "$NIX_CONF.bak.$(date +%s)"
    # Append/merge safely
    awk '
      BEGIN{done=0}
      /^[[:space:]]*experimental-features[[:space:]]*=/ {
        sub(/\r$/,"")
        if ($0 !~ /flakes/) $0=$0" flakes"
        print
        done=1
        next
      }
      { print }
      END{
        if (!done) print "experimental-features = nix-command flakes"
      }
    ' "$NIX_CONF.bak.$(date +%s)" > "$NIX_CONF.tmp" || true
    # Fallback if awk path failed (just ensure the line exists)
    if [ ! -s "$NIX_CONF.tmp" ]; then
      printf "experimental-features = nix-command flakes\n" >> "$NIX_CONF"
    else
      mv -f "$NIX_CONF.tmp" "$NIX_CONF"
    fi
  fi
else
  printf "experimental-features = nix-command flakes\n" > "$NIX_CONF"
fi

# Reload Nix env for good measure
source_nix_env

# --- Step 4: Switch to your HM flake ---
log "Step 4: Switching Home Manager to flake: $HM_FLAKE"
# Using nix run nixpkgs#home-manager as requested
nix run nixpkgs#home-manager -- switch --flake "$HM_FLAKE" -v

log "All done! If HM wrote services/configs, re-login or start your session as needed."
echo "Tip: Override target with:  HM_USER=<user> HM_FLAKE='github:...#<user>' ./setup-pi-hm.sh"
