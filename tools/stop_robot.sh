#!/usr/bin/env bash
set -Eeuo pipefail

pkill -INT -f 'ros2 launch (scout_|scout_web_monitor)' || true
sleep 2
pkill -TERM -f 'rosbridge_websocket|web_video_server|scout_web_monitor|scout_navigation|scout_slam' || true

echo "Stop signal sent to Scout Mini ROS processes."
