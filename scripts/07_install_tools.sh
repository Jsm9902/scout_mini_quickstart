#!/usr/bin/env bash
set -Eeuo pipefail
install_dir="$HOME/.local/bin"; config_dir="$HOME/.config/scout_mini_quickstart"
mkdir -p "$install_dir" "$config_dir"
cat > "$config_dir/runtime.env" <<ENV
ROS_DISTRO=$ROS_DISTRO
WORKSPACE_DIR=$WORKSPACE_DIR
CAN_INTERFACE=$CAN_INTERFACE
WEB_SERVER_PORT=$WEB_SERVER_PORT
ROSBRIDGE_PORT=$ROSBRIDGE_PORT
VIDEO_SERVER_PORT=$VIDEO_SERVER_PORT
ENV
for tool in "$ROOT_DIR"/tools/*.sh; do
  name="$(basename "$tool" .sh)"; install -m 0755 "$tool" "$install_dir/$name"
done
line='export PATH="$HOME/.local/bin:$PATH"'; grep -Fqx "$line" "$HOME/.bashrc" || echo "$line" >> "$HOME/.bashrc"
echo "[OK] Operator tools installed."
