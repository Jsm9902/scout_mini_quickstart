#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/common.sh"; source "$ROOT_DIR/lib/logging.sh"

[[ -r /etc/os-release ]] || { log_error "/etc/os-release missing"; exit 1; }
source /etc/os-release
[[ "$ID" == "ubuntu" && "$VERSION_ID" == "22.04" ]] || { log_error "Ubuntu 22.04 required. Detected: $ID $VERSION_ID"; exit 1; }
[[ "$(uname -m)" == "x86_64" ]] || { log_error "x86_64 required"; exit 1; }
check_internet || { log_error "Internet connection unavailable"; exit 1; }
require_command sudo
sudo_keepalive
free_gb=$(df -Pk "$HOME" | awk 'NR==2{printf "%d", $4/1024/1024}')
(( free_gb >= MIN_DISK_GB )) || { log_error "At least ${MIN_DISK_GB}GB free space required. Available: ${free_gb}GB"; exit 1; }
if [[ -n "${CONDA_PREFIX:-}" ]]; then log_warn "Conda environment is active: $CONDA_PREFIX"; fi
log_success "Preflight checks passed."
