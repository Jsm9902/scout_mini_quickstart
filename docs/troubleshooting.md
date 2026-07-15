# Troubleshooting

## CAN interface is missing

```bash
ip link show
sudo systemctl status scout-can.service
```

## Workspace does not build

```bash
cd ~/scout_ws
source /opt/ros/humble/setup.bash
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install --event-handlers console_direct+
```

## Web UI cannot connect

Check that ports 8000, 8080 and 9090 are reachable only from the trusted LAN and that ROSBridge and the video server are running.
