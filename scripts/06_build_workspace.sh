#!/usr/bin/env bash
set -Eeuo pipefail
# shellcheck disable=SC1091
source "/opt/ros/$ROS_DISTRO/setup.bash"
cd "$WORKSPACE_DIR"
rosdep install --from-paths src --ignore-src -r -y --rosdistro "$ROS_DISTRO"
rm -rf build log
colcon build --symlink-install --executor parallel --parallel-workers "$BUILD_JOBS" --event-handlers console_direct+
[[ -f install/setup.bash ]] || { echo "[ERROR] Build did not create install/setup.bash"; exit 1; }
config_dir="$HOME/.config/scout_mini_quickstart"
mkdir -p "$config_dir"
cat > "$config_dir/ros_env.sh" <<ENV
export ROS_DOMAIN_ID=$ROS_DOMAIN_ID
export ROS_LOCALHOST_ONLY=$ROS_LOCALHOST_ONLY
export RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION
source /opt/ros/$ROS_DISTRO/setup.bash
source $WORKSPACE_DIR/install/setup.bash
ENV
line='[[ -f "$HOME/.config/scout_mini_quickstart/ros_env.sh" ]] && source "$HOME/.config/scout_mini_quickstart/ros_env.sh"'
grep -Fqx "$line" "$HOME/.bashrc" || echo "$line" >> "$HOME/.bashrc"
echo "[OK] Workspace built."
