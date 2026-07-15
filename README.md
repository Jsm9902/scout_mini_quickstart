# Scout Mini Quickstart

Ubuntu 22.04 신규 설치 환경에서 ROS 2 Humble, Scout Mini 소스, VLP-16, SLAM Toolbox, Navigation2, 안전 제어, ROSBridge 및 Web 관제를 자동 구축하는 배포용 저장소입니다.

## 설치

```bash
git clone https://github.com/Jsm9902/scout_mini_quickstart.git
cd scout_mini_quickstart
cp config/quickstart.env.example config/quickstart.env
nano config/quickstart.env
chmod +x quickstart.sh scripts/*.sh tools/*.sh systemd/scout-can-setup
./quickstart.sh
```

> `sudo ./quickstart.sh`로 실행하지 마세요. 필요한 단계에서만 sudo 비밀번호를 요청합니다.

중단 후 이어서 설치:

```bash
./quickstart.sh --resume
```

전체 재실행:

```bash
./quickstart.sh --force
```

검증만 실행:

```bash
./quickstart.sh --verify-only
```

## 설치 후 운용

새 터미널을 연 뒤:

```bash
scout-manager
```

또는 직접 실행:

```bash
start_slam
start_navigation
start_web_slam
start_web_navigation
check_robot
stop_robot
```

## 검증 범위

설치기는 ROS 패키지, 실제 런처 파일, 런처 파싱, Python 모듈, CAN 부팅 서비스, 운용 명령을 검증합니다. 로봇·CAN·LiDAR가 연결된 상태의 실제 데이터(`/odom`, `/scan`, `/tf`)는 실행 후 `check_robot`으로 검사합니다.

## 중요한 하드웨어 조건

- Ubuntu 22.04 x86_64
- Scout Mini CAN-USB 어댑터가 `can0`으로 인식
- CAN bitrate 500000
- VLP-16과 로봇 PC가 동일 네트워크에 연결
- 기존 `scout_mini` 저장소의 지도 및 센서 설정이 실제 장비와 일치

ROSBridge 9090 포트는 인터넷에 직접 공개하지 마세요.
