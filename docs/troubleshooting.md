# 문제 해결

## CAN이 없음
```bash
ip link
systemctl status scout-can.service
sudo systemctl restart scout-can.service
```
USB-CAN 장치명이 `can0`이 아니라면 `config/quickstart.env`의 `CAN_INTERFACE`를 수정하고 `./quickstart.sh --force`를 실행합니다.

## 빌드 실패
```bash
cd ~/scout_ws
rosdep install --from-paths src --ignore-src -r -y --rosdistro humble
colcon build --symlink-install --executor sequential --event-handlers console_direct+
```

## LiDAR 데이터 없음
PC와 VLP-16의 IP 대역, 방화벽, 센서 IP 설정과 기존 launch/yaml의 device IP를 확인합니다.

## Web 접속 불가
```bash
ss -lntp | grep -E '8000|8080|9090'
ros2 node list | grep -E 'rosbridge|web_video'
```
