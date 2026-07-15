#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$ROOT_DIR/config/quickstart.env}"
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

trap 'echo "[ERROR] Installation stopped at line $LINENO. See: $LOG_FILE" >&2' ERR

if [[ ! -f "$CONFIG_FILE" ]]; then
  cp "$ROOT_DIR/config/quickstart.env.example" "$CONFIG_FILE"
  echo "[INFO] Created $CONFIG_FILE from the example configuration."
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

required_vars=(
  ROS_DISTRO WORKSPACE_DIR SOURCE_REPO SOURCE_BRANCH
  CAN_INTERFACE CAN_BITRATE WEB_SERVER_PORT ROSBRIDGE_PORT VIDEO_SERVER_PORT
  BACKUP_EXISTING_SRC
)
for name in "${required_vars[@]}"; do
  if [[ -z "${!name:-}" ]]; then
    echo "[ERROR] Missing configuration value: $name" >&2
    exit 1
  fi
done

export ROOT_DIR CONFIG_FILE ROS_DISTRO WORKSPACE_DIR SOURCE_REPO SOURCE_BRANCH
export CAN_INTERFACE CAN_BITRATE WEB_SERVER_PORT ROSBRIDGE_PORT VIDEO_SERVER_PORT
export BACKUP_EXISTING_SRC

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

for step in "${steps[@]}"; do
  echo
  echo "============================================================"
  echo "[STEP] $step"
  echo "============================================================"
  bash "$ROOT_DIR/scripts/$step"
done

echo
echo "[SUCCESS] Scout Mini environment installation completed."
echo "[INFO] Restart the terminal or run: source $WORKSPACE_DIR/install/setup.bash"
echo "[INFO] Operator commands: start_slam, start_navigation, start_web_slam, start_web_navigation, check_robot, stop_robot"
echo "[INFO] Installation log: $LOG_FILE"
