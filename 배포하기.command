#!/bin/bash
# Finder에서 더블클릭하면 배포가 실행됩니다.
cd "$(dirname "$0")"
./deploy.sh
echo ""
read -p "엔터를 누르면 창이 닫힙니다..."
