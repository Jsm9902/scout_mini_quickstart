#!/usr/bin/env bash
set -Eeuo pipefail

install_dir="$HOME/.local/bin"
runtime_env="$HOME/.config/scout_mini_quickstart/runtime.env"
mkdir -p "$install_dir" "$(dirname "$runtime_env")"

cat > "$runtime_env" <<ENV
ROS_DISTRO=$ROS_DISTRO
WORKSPACE_DIR=$WORKSPACE_DIR
CAN_INTERFACE=$CAN_INTERFACE
WEB_SERVER_PORT=$WEB_SERVER_PORT
ROSBRIDGE_PORT=$ROSBRIDGE_PORT
VIDEO_SERVER_PORT=$VIDEO_SERVER_PORT
ENV

install -m 0755 "$ROOT_DIR/tools/_common.sh" "$install_dir/_common.sh"

for tool in "$ROOT_DIR"/tools/*.sh; do
  [[ "$(basename "$tool")" == "_common.sh" ]] && continue
  name="$(basename "$tool" .sh)"
  install -m 0755 "$tool" "$install_dir/$name"
done

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "[OK] Operator commands installed to $install_dir"
echo "[OK] Runtime configuration installed to $runtime_env"
