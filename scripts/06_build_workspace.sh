#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck disable=SC1091
source "/opt/ros/$ROS_DISTRO/setup.bash"

cd "$WORKSPACE_DIR"
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install

setup_line="source $WORKSPACE_DIR/install/setup.bash"
if ! grep -Fqx "$setup_line" "$HOME/.bashrc"; then
  echo "$setup_line" >> "$HOME/.bashrc"
fi

echo "[OK] Workspace build completed."
