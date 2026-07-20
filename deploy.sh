#!/bin/bash
# 짐로드 주간 스케줄러 자동배포
# index.html 변경분을 커밋하고 GitHub(main)로 push하면 GitHub Pages가 자동 반영합니다.
# 사용법: ./deploy.sh [커밋메시지]
set -e
cd "$(dirname "$0")"

GITHUB_USER="alsrl229-code"

git fetch origin

if ! git merge-base --is-ancestor origin/main HEAD; then
  echo "⚠️  원격(origin/main)에 로컬에 없는 커밋이 있습니다."
  echo "    (GitHub 웹 업로드 또는 다른 곳에서 push된 경우입니다.)"
  echo "    클로드에게 '원격이랑 로컬 맞춰줘'라고 요청해 정리한 뒤 다시 배포하세요."
  exit 1
fi

if ! git diff --quiet -- index.html || ! git diff --cached --quiet -- index.html; then
  msg="${1:-앱 업데이트 $(date '+%Y-%m-%d %H:%M')}"
  git add index.html
  git commit -m "$msg"
fi

if [ "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)" ]; then
  echo "변경 사항 없음 — 배포할 것이 없습니다."
  exit 0
fi

# gh 활성 계정이 다른 계정(예: Mingkydayo)이면 push 동안만 전환했다가 복원
restore_account=""
if command -v gh >/dev/null 2>&1; then
  active="$(gh api user --jq .login 2>/dev/null || echo "")"
  if [ -n "$active" ] && [ "$active" != "$GITHUB_USER" ]; then
    echo "· gh 계정 전환: $active → $GITHUB_USER (push 후 복원됩니다)"
    gh auth switch --hostname github.com --user "$GITHUB_USER"
    restore_account="$active"
  fi
fi

push_result=0
git push origin main || push_result=$?

if [ -n "$restore_account" ]; then
  gh auth switch --hostname github.com --user "$restore_account" >/dev/null 2>&1 || true
  echo "· gh 계정 복원: $restore_account"
fi

if [ "$push_result" -ne 0 ]; then
  echo "⚠️  push 실패 — 클로드에게 알려주세요."
  exit "$push_result"
fi

echo ""
echo "✅ 배포 완료! 1~2분 뒤 아래 주소에 반영됩니다."
echo "   https://alsrl229-code.github.io/gymlord-weekly-scheduler/"
