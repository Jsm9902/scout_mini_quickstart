#!/usr/bin/env bash
set -Eeuo pipefail
RUNTIME_ENV="${SCOUT_RUNTIME_ENV:-$HOME/.config/scout_mini_quickstart/runtime.env}"
[[ -f "$RUNTIME_ENV" ]] || { echo "[ERROR] Run quickstart.sh first."; exit 1; }
# shellcheck disable=SC1090
source "$RUNTIME_ENV"
# shellcheck disable=SC1090
source "$HOME/.config/scout_mini_quickstart/ros_env.sh"
