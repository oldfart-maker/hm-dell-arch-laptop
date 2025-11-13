#!/usr/bin/env bash
# target-setup.sh
#
# Usage (on TARGET):
#   ./target-setup.sh <HOST_IP> -u <HOST_USER> [-P <HOST_PASSWORD>] [--no-strict]
#
# - HOST_IP      : IP of the host machine (where we pull from)
# - -u HOST_USER : username on the host (for scp pulls)
# - -P HOST_PASS : optional, use sshpass to supply host password (insecure; visible in ps/history)
# - --no-strict  : optional, do NOT set StrictHostKeyChecking=accept-new (use SSH defaults)
#
# Behavior:
# - If run as root:
#     * enables sshd (so you can monitor from host)
#     * re-execs itself as LOCAL_USER="username"
# - If run as non-root (username):
#     * runs Nix, Home Manager, flakes, nixGL, wallpapers, api-keys pull
#
# All network setup is assumed already done (Wi-Fi up, DNS working).

set -euo pipefail
IFS=$'\n\t'

progname="$(basename "$0")"

export HOST_IP=192.168.1.80
export HOST_USER=username
export HOST_PASS=Hangout2016!
export HOST_PASS=1

print_usage() {
  cat <<EOF
Usage: $progname <HOST_IP> -u <HOST_USER> [-P <HOST_PASSWORD>] [--no-strict]

Examples:
  $progname 192.168.1.80 -u mike
  $progname 192.168.1.80 -u mike -P 'host-password' --no-strict
EOF
}

# --- Argument parsing ---

if [[ $# -lt 1 ]]; then
  print_usage
  exit 2
fi

HOST_IP="$1"
shift

HOST_USER=""
HOST_PASS=""
NO_STRICT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--user)
      HOST_USER="${2:-}"
      shift 2
      ;;
    -P|--password)
      HOST_PASS="${2:-}"
      shift 2
      ;;
    --no-strict)
      NO_STRICT=true
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      print_usage
      exit 2
      ;;
  esac
done

if [[ -z "$HOST_USER" ]]; then
  echo "ERROR: host username is required (-u)."
  print_usage
  exit 2
fi

# --- Root → non-root flip ---

if [[ "$EUID" -eq 0 ]]; then
  # Target login user on the newly installed system.
  LOCAL_USER="username"

  echo "Running as root. Enabling sshd, then re-running as ${LOCAL_USER}..."
  systemctl enable sshd --now || true

  # Re-exec this script as LOCAL_USER with the same arguments.
  # Note: HOST_PASS should not contain spaces or crazy shell chars.
  exec su - "${LOCAL_USER}" -c "$0 ${HOST_IP} -u ${HOST_USER} ${HOST_PASS:+-P ${HOST_PASS}} ${NO_STRICT:+--no-strict}"
fi

# From here on, we are non-root (running as LOCAL_USER or direct login user).

# --- SCP config and helpers ---

if [[ "$NO_STRICT" = true ]]; then
  SCP_OPTS="-o ConnectTimeout=10"
else
  SCP_OPTS="-o StrictHostKeyChecking=accept-new -o ConnectTimeout=10"
fi

run_scp() {
  # Usage: run_scp source target
  if [[ -n "$HOST_PASS" ]]; then
    if ! command -v sshpass >/dev/null 2>&1; then
      echo "ERROR: sshpass not found, but -P/HOST_PASS was provided."
      echo "Install sshpass or omit -P."
      exit 3
    fi
    # shellcheck disable=SC2086
    sshpass -p "$HOST_PASS" scp $SCP_OPTS "$@"
  else
    # shellcheck disable=SC2086
    scp $SCP_OPTS "$@"
  fi
}

echo "=== target-setup.sh (pull-from-host) ==="
echo "Host: ${HOST_USER}@${HOST_IP}"
[[ -n "$HOST_PASS" ]] && echo "Note: using sshpass (password visible to local process list)."

# Ensure sshd is enabled even if we started as non-root
echo
echo "-> Ensuring sshd is enabled (will prompt for sudo password if needed)"
if command -v sudo >/dev/null 2>&1; then
  sudo systemctl enable sshd --now || true
else
  echo "sudo not found; assuming sshd already handled when script ran as root."
fi

# Prep local directories
echo
echo "-> Creating local directories"
mkdir -p "$HOME/.config/emacs-common" "$HOME/Pictures/wallpapers"

# -------------------------------------------------------------------
# Step 1 - Install Nix (no-daemon) if missing
# -------------------------------------------------------------------
echo
echo "-> Step 1: Installing Nix (no-daemon) if not already installed"
if command -v nix >/dev/null 2>&1; then
  echo "nix already present; skipping installer"
else
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
fi

# Source Nix profile if available
if [[ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
  # shellcheck disable=SC1090
  . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
  echo "Sourced nix profile"
else
  echo "Warning: nix profile not found at ~/.nix-profile/etc/profile.d/nix.sh (may require new login)."
fi

# -------------------------------------------------------------------
# Step 2 - Home Manager install via channel
# -------------------------------------------------------------------
echo
echo "-> Step 2: Setting up Home Manager channel and installing"
if ! nix-channel --list | grep -q "home-manager"; then
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
fi
nix-channel --update
nix-shell '<home-manager>' -A install || echo "Warning: home-manager install returned non-zero status"

# -------------------------------------------------------------------
# Step 3 - Enable flakes and nix-command
# -------------------------------------------------------------------
echo
echo "-> Step 3: Enabling flakes and nix-command"
mkdir -p "${HOME}/.config/nix"
printf "experimental-features = nix-command flakes\n" > "${HOME}/.config/nix/nix.conf"
if [[ -f "${HOME}/.nix-profile/etc/profile.d/nix.sh" ]]; then
  # shellcheck disable=SC1090
  . "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi
hash -r

# -------------------------------------------------------------------
# Step 3.1 - Install nixGL for Wayland compatibility
# -------------------------------------------------------------------
echo
echo "-> Step 3.1: Installing nixGL via channel"
if ! nix-channel --list | grep -q "nixgl"; then
  nix-channel --add https://github.com/nix-community/nixGL/archive/main.tar.gz nixgl
fi
nix-channel --update
nix-env -iA nixgl.auto.nixGLDefault || echo "Warning: nix-env -iA nixgl.auto.nixGLDefault failed"

# -------------------------------------------------------------------
# Step 4 - home-manager switch via flake
# -------------------------------------------------------------------
echo
echo "-> Step 4: Running home-manager switch via flake"
FLAKE_REF="github:oldfart-maker/hm-dell-arch-laptop#username"
if command -v nix >/dev/null 2>&1; then
  nix run nixpkgs#home-manager -- switch --flake "${FLAKE_REF}" -v --refresh || {
    echo "Warning: home-manager flake switch returned non-zero. Inspect output for details."
  }
else
  echo "nix not found; skipping flake switch step"
fi

# -------------------------------------------------------------------
# Step 5 - SKIPPED (vterm-shell)
# -------------------------------------------------------------------
echo
echo "-> Step 5: SKIPPED (you will set vterm-shell in Emacs manually)"

# -------------------------------------------------------------------
# Step 6 - Prime wallpapers from arch-wallpapers/png
# -------------------------------------------------------------------
echo
echo "-> Step 6: Cloning arch-wallpapers and moving all *.png into ~/Pictures/wallpapers"
TMP_DIR="$(mktemp -d)"
pushd "$TMP_DIR" >/dev/null

if git clone https://github.com/greatbot6120/arch-wallpapers.git; then
  if [[ -d arch-wallpapers/png ]]; then
    mkdir -p "${HOME}/Pictures/wallpapers"
    shopt -s nullglob
    PNGS=(arch-wallpapers/png/*.png)
    if [[ ${#PNGS[@]} -gt 0 ]]; then
      mv arch-wallpapers/png/*.png "${HOME}/Pictures/wallpapers/"
      echo "Moved ${#PNGS[@]} PNG(s) to ${HOME}/Pictures/wallpapers"
    else
      echo "No PNG files found in arch-wallpapers/png"
    fi
    shopt -u nullglob
  else
    echo "Warning: arch-wallpapers/png directory not found in cloned repo"
  fi
  rm -rf arch-wallpapers
else
  echo "Warning: git clone failed for arch-wallpapers"
fi

popd >/dev/null
rm -rf "$TMP_DIR"

# -------------------------------------------------------------------
# Step 7 - Pull api-keys.el from host to target
# -------------------------------------------------------------------
echo
echo "-> Step 7: Pulling ~/.config/emacs-common/api-keys.el from host to target"
REMOTE_API="~/.config/emacs-common/api-keys.el"
LOCAL_DIR="${HOME}/.config/emacs-common"
LOCAL_DEST="${LOCAL_DIR}/api-keys.el"

mkdir -p "${LOCAL_DIR}"
if run_scp "${HOST_USER}@${HOST_IP}:${REMOTE_API}" "${LOCAL_DEST}"; then
  echo "Copied API keys to ${LOCAL_DEST}"
else
  echo "Warning: failed to copy API keys from ${HOST_USER}@${HOST_IP}:${REMOTE_API}"
fi

echo
echo "=== Finished target-setup.sh ==="
echo "Steps completed: 1,2,3,3.1,4,6,7 (5 skipped intentionally)."
echo "sshd should now be enabled; you can monitor this target from the host."
