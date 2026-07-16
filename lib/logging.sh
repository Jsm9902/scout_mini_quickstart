#!/usr/bin/env bash
set -Eeuo pipefail

init_logging() {
  mkdir -p "$ROOT_DIR/logs"
  LOG_FILE="$ROOT_DIR/logs/install_$(date +%Y%m%d_%H%M%S).log"
  export LOG_FILE
  exec > >(tee -a "$LOG_FILE") 2>&1
  echo "[INFO] Log: $LOG_FILE"
}
log_info(){ echo "[INFO] $*"; }
log_warn(){ echo "[WARN] $*"; }
log_error(){ echo "[ERROR] $*"; }
log_success(){ echo "[OK] $*"; }
on_error(){ local code="$1" line="$2"; log_error "Installation stopped (exit=$code, line=$line)"; log_info "Fix the cause and rerun ./install.sh --resume"; exit "$code"; }
