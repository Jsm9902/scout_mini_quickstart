# Scout Mini Quickstart v2.1

Ubuntu 22.04에서 ROS2 Humble, Scout Mini 드라이버, Velodyne, SLAM,
Navigation2, 안전 제어 및 Web 관제 환경을 자동으로 구축하는 설치기입니다.

지원 환경:

- Ubuntu 22.04 x86_64 Mini PC
- NVIDIA Jetson Orin Nano / ARM64
- ROS2 Humble
- Scout Mini
- Velodyne VLP-16
- RealSense 선택 지원

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

## Jetson CAN 구성

Jetson은 내장 CAN과 USB-CAN의 이름 충돌을 방지하기 위해 다음 이름을 사용합니다.

```text
USB-CAN (gs_usb)        -> can0
Jetson 내장 CAN(mttcan) -> can_internal
```

Quickstart가 다음 파일을 자동으로 설치합니다.

```text
/etc/systemd/network/10-mttcan.link
/etc/systemd/network/11-gs-usb.link
```

첫 설치 후 `can0`가 `gs_usb`가 아니라면 한 번 재부팅합니다.

```bash
sudo reboot
```

재부팅 후 확인:

```bash
ip -br link | grep -E 'can0|can_internal'
readlink -f /sys/class/net/can0/device/driver
scout-can-check
```

기대 결과:

```text
can0         -> gs_usb
can_internal -> mttcan
can0 bitrate -> 500000
```

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

새 터미널에서 명령어를 찾지 못하면 다음을 실행합니다.

```bash
source ~/.bashrc
```

## 빠른 실행 가이드

### 1. 설치 상태 확인

```bash
scout-check
scout-can-check
```

### 2. 기본 구동

```bash
scout-start-base
```

### 3. SLAM 실행

RViz 기반 SLAM:

```bash
scout-start-slam
```

Web 관제 기반 SLAM:

```bash
scout-start-web-slam
```

### 4. Navigation 실행

RViz 기반 Navigation:

```bash
scout-start-navigation
```

Web 관제 기반 Navigation:

```bash
scout-start-web-navigation
```

### 5. 전체 종료

```bash
scout-stop
```

## Web Monitor

Web Monitor는 SLAM 또는 Navigation 실행 명령에 포함되어 실행됩니다.

SLAM Web 관제:

```bash
scout-start-web-slam
```

Navigation Web 관제:

```bash
scout-start-web-navigation
```

로봇의 IP 주소 확인:

```bash
hostname -I
```

브라우저 접속:

```text
http://<ROBOT_IP>:8000
```

기본 포트:

| 서비스 | 포트 |
|---|---:|
| Web UI | 8000 |
| ROSBridge WebSocket | 9090 |
| Web Video Server | 8080 |

Web Monitor에서 사용할 수 있는 주요 기능:

- 지도 표시
- 로봇 위치 표시
- 목표 지점 지정
- 수동 조작
- SLAM 및 Navigation 모드 실행
- 카메라 영상 확인
- 로봇 상태 확인

## 하드웨어 기본값

- CAN 인터페이스: `can0`
- CAN bitrate: `500000`
- ROSBridge: `9090`
- Video Server: `8080`
- Web Server: `8000`

실제 CAN 어댑터, Velodyne IP 및 카메라 연결은 하드웨어 환경에 맞춰 확인해야 합니다.

## 문제 해결

### Web 화면이 열리지 않음

서비스 포트를 확인합니다.

```bash
ss -lntp | grep -E ':8000|:8080|:9090'
```

로봇과 접속 PC가 같은 네트워크인지 확인합니다.

```bash
hostname -I
```

브라우저에서는 `localhost`가 아니라 로봇의 실제 IP를 사용합니다.

```text
http://<ROBOT_IP>:8000
```

### Web에서 Robot Offline 표시

먼저 CAN을 확인합니다.

```bash
scout-can-check
ip -details link show can0
systemctl status scout-can.service --no-pager
```

Scout Base가 실행 중인지 확인합니다.

```bash
ros2 node list | grep scout
ros2 topic list | grep -E 'cmd_vel|odom|battery'
```

### Jetson에서 can0가 gs_usb가 아님

```bash
readlink -f /sys/class/net/can0/device/driver
```

`mttcan`으로 표시되면 `.link` 규칙 적용을 위해 재부팅합니다.

```bash
sudo reboot
```

### gs_usb 모듈 없음

```bash
modinfo gs_usb
```

모듈을 찾을 수 없다면 현재 Jetson 커널용 `gs_usb` 모듈을 설치해야 합니다.
모듈 설치 후 다음 명령으로 확인합니다.

```bash
sudo modprobe gs_usb
lsmod | grep gs_usb
```

### Velodyne 데이터가 없음

```bash
ros2 topic list | grep velodyne
ros2 topic hz /velodyne_points
```

Velodyne과 Jetson 또는 Mini PC의 IP 대역이 같은지 확인합니다.

### Web 관련 ROS 패키지 확인

```bash
ros2 pkg prefix scout_web_monitor
ros2 pkg prefix rosbridge_server
ros2 pkg prefix web_video_server
```

## 업데이트 검증

```bash
bash -n steps/05_can.sh
bash -n steps/07_jetson.sh
bash -n steps/09_hardware_verify.sh
./install.sh --verify-only
```
