# Troubleshooting

## AMENT_TRACE_SETUP_FILES: unbound variable
본 설치기는 ROS setup source 중 `set -u`를 임시 해제합니다. 직접 스크립트를 수정했다면 같은 안전 source 함수를 사용하세요.

## CAN 장치 없음
`ip link`와 `lsusb`를 확인하고 USB-to-CAN 드라이버 및 장치명을 확인하세요.

## 빌드 실패
설치 로그를 확인하고 `./install.sh --resume`을 실행하세요.

## Web 접속 실패
9090, 8080, 8000 포트와 방화벽, ROSBridge 및 Video Server 실행 상태를 확인하세요.
