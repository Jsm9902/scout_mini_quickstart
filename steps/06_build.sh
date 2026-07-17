#!/usr/bin/env bash
set -Eeuo pipefail
source "$ROOT_DIR/lib/common.sh"; source "$ROOT_DIR/lib/logging.sh"
safe_source "/opt/ros/${ROS_DISTRO}/setup.bash"
cd "$WORKSPACE_DIR"
if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then sudo rosdep init || true; fi
rosdep update
rosdep install --from-paths src --ignore-src --rosdistro "$ROS_DISTRO" -r -y
rm -rf build log
colcon build --symlink-install --parallel-workers "$BUILD_JOBS" --event-handlers console_direct+
[[ -f "$WORKSPACE_DIR/install/setup.bash" ]] || { log_error "Workspace setup file not created"; exit 1; }
config_dir="$HOME/.config/scout_mini_quickstart"
mkdir -p "$config_dir"
cat > "$config_dir/ros_env.sh" <<EOF_ENV
#!/usr/bin/env bash
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID}"
export ROS_LOCALHOST_ONLY="${ROS_LOCALHOST_ONLY}"
export RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION}"
_had_u=0; case "\$-" in *u*) _had_u=1; set +u;; esac
source "/opt/ros/${ROS_DISTRO}/setup.bash"
source "${WORKSPACE_DIR}/install/setup.bash"
[[ \$_had_u -eq 1 ]] && set -u
unset _had_u
EOF_ENV
chmod +x "$config_dir/ros_env.sh"
line='[[ -f "$HOME/.config/scout_mini_quickstart/ros_env.sh" ]] && source "$HOME/.config/scout_mini_quickstart/ros_env.sh"'
grep -Fqx "$line" "$HOME/.bashrc" || echo "$line" >> "$HOME/.bashrc"
log_success "Workspace built successfully."
