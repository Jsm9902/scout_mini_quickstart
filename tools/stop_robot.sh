#!/usr/bin/env bash
set -Eeuo pipefail
pkill -INT -f 'ros2 launch (scout_|scout_web_monitor)' || true
sleep 3
pkill -TERM -f 'rosbridge_websocket|web_video_server|scout_navigation|scout_slam|scout_base' || true
echo "Stop signals sent. Confirm with: ros2 node list"
