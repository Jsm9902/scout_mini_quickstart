#!/usr/bin/env bash
set -Eeuo pipefail
pkill -INT -f 'ros2 launch' || true
pkill -INT -f 'rosbridge_websocket' || true
pkill -INT -f 'web_video_server' || true
echo "Stop signal sent to Scout Mini ROS processes."
