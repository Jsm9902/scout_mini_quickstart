#!/usr/bin/env bash
set -Eeuo pipefail

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/logging.sh"

if [[ ! -r /etc/os-release ]]; then
    log_error "/etc/os-release missing"
    exit 1
fi

# shellcheck disable=SC1091
source /etc/os-release

if [[ "${ID:-}" != "ubuntu" || "${VERSION_ID:-}" != "22.04" ]]; then
    log_error "Ubuntu 22.04 required."
    log_error "Detected: ${ID:-unknown} ${VERSION_ID:-unknown}"
    exit 1
fi

ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        log_info "Supported architecture detected: x86_64"
        ;;
    aarch64|arm64)
        log_info "Supported architecture detected: $ARCH"
        log_info "Jetson / ARM64 environment detected."
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        log_error "Supported architectures: x86_64, aarch64, arm64"
        exit 1
        ;;
esac

check_internet || {
    log_error "Internet connection unavailable"
    exit 1
}

require_command sudo
sudo_keepalive

free_gb="$(
    df -Pk "$HOME" |
        awk 'NR == 2 {printf "%d", $4 / 1024 / 1024}'
)"

if [[ -z "$free_gb" || ! "$free_gb" =~ ^[0-9]+$ ]]; then
    log_error "Unable to determine free disk space."
    exit 1
fi

if (( free_gb < MIN_DISK_GB )); then
    log_error "At least ${MIN_DISK_GB}GB free space required."
    log_error "Available: ${free_gb}GB"
    exit 1
fi

if [[ -n "${CONDA_PREFIX:-}" ]]; then
    log_warn "Conda environment is active: $CONDA_PREFIX"
fi

log_success "Preflight checks passed."