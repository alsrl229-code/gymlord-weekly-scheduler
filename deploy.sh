#!/bin/bash
# 짐로드 주간 스케줄러 자동배포
# index.html 변경분을 커밋하고 GitHub(main)로 push하면 GitHub Pages가 자동 반영합니다.
# 사용법: ./deploy.sh [커밋메시지]
set -e
cd "$(dirname "$0")"

git fetch origin

if ! git merge-base --is-ancestor origin/main HEAD; then
  echo "⚠️  원격(origin/main)에 로컬에 없는 커밋이 있습니다."
  echo "    (GitHub 웹 업로드 또는 다른 곳에서 push된 경우입니다.)"
  echo "    클로드에게 '원격이랑 로컬 맞춰줘'라고 요청해 정리한 뒤 다시 배포하세요."
  exit 1
fi

if git diff --quiet -- index.html && git diff --cached --quiet -- index.html; then
  echo "변경 사항 없음 — 배포할 것이 없습니다."
  exit 0
fi

msg="${1:-앱 업데이트 $(date '+%Y-%m-%d %H:%M')}"
git add index.html
git commit -m "$msg"
git push origin main

echo ""
echo "✅ 배포 완료! 1~2분 뒤 아래 주소에 반영됩니다."
echo "   https://alsrl229-code.github.io/gymlord-weekly-scheduler/"
