#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROOT_DIR

source "$ROOT_DIR/lib/common.sh"
source "$ROOT_DIR/lib/logging.sh"
source "$ROOT_DIR/lib/state.sh"
source "$ROOT_DIR/lib/ros.sh"

CONFIG_FILE="$ROOT_DIR/config/scout.env"
EXAMPLE_FILE="$ROOT_DIR/config/scout.env.example"

RESUME=0
FORCE=0
VERIFY_ONLY=0
DEVELOPER_TOOLS=0

usage() {
  cat <<USAGE
Usage: ./install.sh [options]

Options:
  --resume            Resume from the first incomplete step
  --force             Re-run all steps and overwrite generated files
  --verify-only       Run static and hardware verification only
  --developer-tools   Install optional developer utilities
  -h, --help          Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --resume) RESUME=1 ;;
    --force) FORCE=1 ;;
    --verify-only) VERIFY_ONLY=1 ;;
    --developer-tools) DEVELOPER_TOOLS=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 2 ;;
  esac
  shift
done

if [[ $EUID -eq 0 ]]; then
  echo "[ERROR] Do not run this installer with sudo. Run: ./install.sh"
  exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  cp "$EXAMPLE_FILE" "$CONFIG_FILE"
  echo "[INFO] Created $CONFIG_FILE from example."
fi

# shellcheck disable=SC1090
set -a
source "$CONFIG_FILE"
set +a

export RESUME FORCE VERIFY_ONLY DEVELOPER_TOOLS
export CONFIG_FILE

init_logging
trap 'on_error $? $LINENO' ERR

if [[ "$VERIFY_ONLY" -eq 1 ]]; then
  run_step "$ROOT_DIR/steps/07_static_verify.sh"
  run_step "$ROOT_DIR/steps/09_hardware_verify.sh"
  exit 0
fi

STEPS=(
  00_preflight.sh
  01_system_packages.sh
  02_ros2_humble.sh
  03_ros_dependencies.sh
  04_workspace.sh
  05_can.sh
  06_build.sh
  07_static_verify.sh
  08_install_commands.sh
  09_hardware_verify.sh
)

for step in "${STEPS[@]}"; do
  run_step "$ROOT_DIR/steps/$step"
done

log_success "Scout Mini Quickstart installation completed."
log_info "Open a new terminal or run: source ~/.config/scout_mini_quickstart/ros_env.sh"
log_info "Then start with: scout-manager"
