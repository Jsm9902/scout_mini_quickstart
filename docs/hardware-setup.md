# Hardware setup

1. Connect the Scout Mini CAN adapter and verify that Linux creates `can0`.
2. Connect the Velodyne VLP-16 and configure the host Ethernet interface in the same subnet as the LiDAR.
3. Connect the camera used by the web video server.
4. Keep ROSBridge ports inside a trusted local network. Do not expose port 9090 directly to the public internet.
