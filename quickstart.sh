#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$ROOT_DIR/config/quickstart.env}"
LOG_DIR="$ROOT_DIR/logs"
STATE_DIR="$ROOT_DIR/.state"
mkdir -p "$LOG_DIR" "$STATE_DIR"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

on_error() {
  local exit_code=$?
  echo "[ERROR] Installation stopped (exit=$exit_code, line=${BASH_LINENO[0]})."
  echo "[ERROR] Log: $LOG_FILE"
  echo "[INFO] Fix the cause and rerun ./quickstart.sh --resume"
  exit "$exit_code"
}
trap on_error ERR

if [[ $EUID -eq 0 ]]; then
  echo "[ERROR] Do not run quickstart.sh with sudo. Run it as the normal robot user."
  echo "        The installer requests sudo only for system packages/services."
  exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  cp "$ROOT_DIR/config/quickstart.env.example" "$CONFIG_FILE"
  echo "[INFO] Created configuration: $CONFIG_FILE"
fi
# shellcheck disable=SC1090
source "$CONFIG_FILE"

MODE="install"
RESUME=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --resume) RESUME=1 ;;
    --force) FORCE=1 ;;
    --verify-only) MODE="verify" ;;
    --help|-h)
      cat <<HELP
Usage: ./quickstart.sh [--resume] [--force] [--verify-only]
  --resume       Skip steps previously completed successfully
  --force        Run every installation step again
  --verify-only  Run static installation verification only
HELP
      exit 0 ;;
    *) echo "[ERROR] Unknown option: $arg"; exit 2 ;;
  esac
done

required=(ROS_DISTRO WORKSPACE_DIR SOURCE_REPO SOURCE_BRANCH SOURCE_POLICY BUILD_JOBS CAN_INTERFACE CAN_BITRATE ENABLE_CAN_SERVICE ROS_DOMAIN_ID ROS_LOCALHOST_ONLY RMW_IMPLEMENTATION WEB_SERVER_PORT ROSBRIDGE_PORT VIDEO_SERVER_PORT INSTALL_REALSENSE INSTALL_V4L2_CAMERA RUN_HARDWARE_SMOKE_TEST)
for var in "${required[@]}"; do
  [[ -n "${!var:-}" ]] || { echo "[ERROR] Missing config: $var"; exit 1; }
done

export ROOT_DIR CONFIG_FILE STATE_DIR ROS_DISTRO WORKSPACE_DIR SOURCE_REPO SOURCE_BRANCH SOURCE_POLICY BUILD_JOBS
export CAN_INTERFACE CAN_BITRATE ENABLE_CAN_SERVICE ROS_DOMAIN_ID ROS_LOCALHOST_ONLY RMW_IMPLEMENTATION
export WEB_SERVER_PORT ROSBRIDGE_PORT VIDEO_SERVER_PORT INSTALL_REALSENSE INSTALL_V4L2_CAMERA RUN_HARDWARE_SMOKE_TEST

steps=(
  01_check_system.sh
  02_install_ros2.sh
  03_install_dependencies.sh
  04_setup_workspace.sh
  05_setup_can.sh
  06_build_workspace.sh
  07_install_tools.sh
  08_verify_installation.sh
)
[[ "$MODE" == "verify" ]] && steps=(08_verify_installation.sh)

for step in "${steps[@]}"; do
  marker="$STATE_DIR/${step%.sh}.done"
  if [[ "$FORCE" -eq 0 && "$RESUME" -eq 1 && -f "$marker" ]]; then
    echo "[SKIP] $step (completed previously)"
    continue
  fi
  echo
  echo "============================================================"
  echo "[STEP] $step"
  echo "============================================================"
  bash "$ROOT_DIR/scripts/$step"
  date -Is > "$marker"
done

echo
echo "============================================================"
echo "[SUCCESS] Scout Mini Quickstart installation completed."
echo "============================================================"
echo "Open a new terminal, then run: scout-manager"
echo "Direct commands: start_slam, start_navigation, start_web_slam, start_web_navigation, check_robot, stop_robot"
echo "Log: $LOG_FILE"
