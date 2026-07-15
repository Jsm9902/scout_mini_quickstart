#!/usr/bin/env bash
set -Eeuo pipefail

RUNTIME_ENV="${SCOUT_RUNTIME_ENV:-$HOME/.config/scout_mini_quickstart/runtime.env}"
if [[ ! -f "$RUNTIME_ENV" ]]; then
  echo "[ERROR] Runtime configuration not found: $RUNTIME_ENV" >&2
  echo "        Run quickstart.sh first." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$RUNTIME_ENV"
# shellcheck disable=SC1090
source "/opt/ros/$ROS_DISTRO/setup.bash"
# shellcheck disable=SC1090
source "$WORKSPACE_DIR/install/setup.bash"
