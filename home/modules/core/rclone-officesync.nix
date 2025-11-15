{ config, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;
in
{
  # your bisync script
  home.file.".local/bin/officesync.sh" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      REMOTE_DIR='gdrive:Office-Docs (Global Sync)'
      LOCAL_DIR="$HOME/Documents/Office-Docs (Global Sync)"

      CACHE_DIR="$HOME/.cache/rclone"
      LOG="$CACHE_DIR/officesync.log"
      LOCK="$CACHE_DIR/officesync.lock"
      REPAIR="$HOME/.local/bin/repair_remote_docs.sh"     # <- your repair script

      mkdir -p "$LOCAL_DIR" "$CACHE_DIR"

      # single-instance lock
      exec 9>"$LOCK"
      if ! flock -n 9; then
        echo "$(date -Is) already running; exiting" >> "$LOG"
        exit 0
      fi

      log() { echo "$(date -Is) $*" >> "$LOG"; }

      run_bisync() {
        nice -n 10 ionice -c2 -n7 rclone bisync "$LOCAL_DIR" "$REMOTE_DIR" \
          --conflict-resolve newer \
          --create-empty-src-dirs \
          --drive-skip-gdocs \
          --retries 1 --low-level-retries 1 \
          --log-file "$LOG" --log-level INFO -P
      }

      # 1) pre-repair
      if [[ -x "$REPAIR" ]]; then
        log "running repair: $REPAIR $REMOTE_DIR"
        nice -n 10 ionice -c2 -n7 "$REPAIR" "$REMOTE_DIR" >> "$LOG" 2>&1 || true
      else
        log "repair script not found at $REPAIR (skipping)"
      fi

      # 2) first attempt
      log "bisync: first attempt"
      if run_bisync; then
        log "bisync: success"
        exit 0
      fi

      # 3) fallback: repair again + one-time --resync, then a final normal pass
      log "bisync failed; attempting repair + --resync"
      [[ -x "$REPAIR" ]] && nice -n 10 ionice -c2 -n7 "$REPAIR" "$REMOTE_DIR" >> "$LOG" 2>&1 || true

      # one-time resync to rebuild baselines if needed
      if nice -n 10 ionice -c2 -n7 rclone bisync "$LOCAL_DIR" "$REMOTE_DIR" \
            --resync --conflict-resolve newer \
            --create-empty-src-dirs \
            --drive-skip-gdocs \
            --retries 1 --low-level-retries 1 \
            --filter-from "$HOME/.config/rclone/officesync.filter" \
            --log-file "$LOG" --log-level INFO -P; then
        log "bisync --resync: success; running final normal pass"
        if run_bisync; then
          log "bisync: success after resync"
          exit 0
        fi
      fi

      log "bisync: still failing after repair + resync"
      exit 1
    '';
    executable = true;
  };
}
