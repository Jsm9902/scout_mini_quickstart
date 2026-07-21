# Scout Mini Quickstart v2

Ubuntu 22.04에서 ROS2 Humble, Scout Mini 드라이버, Velodyne, SLAM, Navigation2, 안전 제어, Web 관제를 자동 구축하는 설치기입니다.

## 설치

```bash
git clone https://github.com/Jsm9902/scout_mini_quickstart.git
cd scout_mini_quickstart
cp config/scout.env.example config/scout.env
nano config/scout.env
./install.sh
```

중단 후 재개:

```bash
./install.sh --resume
```

검증만 실행:

```bash
./install.sh --verify-only
```

> `sudo ./install.sh`로 실행하지 마세요.

## 설치 후 명령

```text
scout-manager
scout-build
scout-start-base
scout-start-slam
scout-start-navigation
scout-start-web-slam
scout-start-web-navigation
scout-check
scout-can-check
scout-stop
```

## 하드웨어 기본값

- CAN: `can0`, 500000 bps
- ROSBridge: 9090
- Video Server: 8080
- Web Server: 8000

실제 CAN 어댑터, Velodyne IP, 카메라 연결은 하드웨어 환경에 맞춰 확인해야 합니다.
