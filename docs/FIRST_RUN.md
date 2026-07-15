# 최초 실장비 실행 순서

1. CAN 어댑터와 VLP-16을 연결합니다.
2. 재부팅 후 `systemctl status scout-can.service`를 확인합니다.
3. `start_slam` 또는 `start_web_slam`을 실행합니다.
4. 새 터미널에서 `check_robot`을 실행해 `/odom`, `/scan`, `/tf` 데이터가 수신되는지 확인합니다.
5. 지도를 생성·저장한 뒤 Navigation을 실행합니다.
6. Web 관제는 `hostname -I`의 첫 IP와 8000 포트로 접속합니다.

설치기는 안전을 위해 자동으로 모터 명령을 발행하지 않습니다.
