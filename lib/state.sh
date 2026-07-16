#!/usr/bin/env bash
set -Eeuo pipefail
STATE_DIR="$ROOT_DIR/.state"
mkdir -p "$STATE_DIR"
step_key(){ basename "$1" .sh; }
step_done(){ [[ -f "$STATE_DIR/$(step_key "$1").done" ]]; }
mark_done(){ date -Is > "$STATE_DIR/$(step_key "$1").done"; }
run_step(){
  local step="$1"
  local key
  key="$(step_key "$step")"
  echo
  echo "==================================================="
  echo "[STEP] $key"
  echo "==================================================="
  if [[ "${FORCE:-0}" -eq 0 && "${RESUME:-0}" -eq 1 ]] && step_done "$step"; then
    echo "[SKIP] Already completed: $key"
    return 0
  fi
  bash "$step"
  mark_done "$step"
}
