# GitHub Pages + Supabase 배포 가이드

## 1. 공개 전 개인정보 확인

현재 공개용 `index.html`의 기본 회원은 예시 데이터입니다. 실제 회원 초기 데이터는 로컬 전용 백업으로 따로 저장되어 있습니다.

- 로컬 백업: `private/짐로드_실회원_초기데이터.private.json`
- GitHub에 올리면 안 되는 파일: `private/`, `index.backup-*.html`, `짐로드_PT회원_정리.csv`

`.gitignore`에 위 파일들이 등록되어 있으니, 앱 폴더만 새 저장소로 올리면 실회원 정보가 공개 코드에 들어가지 않습니다.

## 2. Supabase 설정

1. Supabase에서 새 프로젝트를 만듭니다.
2. SQL Editor에서 `supabase/schema.sql` 내용을 실행합니다.
3. Authentication 설정에서 Email 로그인을 켭니다.
4. Google 로그인을 쓰려면 Authentication > Providers > Google을 켜고 Google OAuth Client ID/Secret을 입력합니다.
5. Authentication > URL Configuration에 배포 주소를 등록합니다.

예시 Redirect URL:

- 로컬 테스트: `http://localhost:4173`
- GitHub Pages: `https://GITHUB_ID.github.io/REPOSITORY_NAME/`

6. Project Settings > API에서 Project URL과 anon/public key를 복사합니다.
7. `config.js`에 붙여넣습니다.

```js
window.GYMLORD_SUPABASE = {
  url: "https://YOUR_PROJECT.supabase.co",
  anonKey: "YOUR_ANON_OR_PUBLISHABLE_KEY",
  table: "trainer_scheduler_states"
};
```

## 3. 로컬 테스트

OAuth 로그인을 테스트할 때는 `file://` 대신 로컬 서버로 여는 편이 안정적입니다.

```bash
cd /Users/mingki/Desktop/AI/짐로드/짐로드_주간스케줄_관리도구
python3 -m http.server 4173
```

브라우저에서 `http://localhost:4173`으로 접속합니다.

## 4. GitHub에 앱만 올리기

큰 `짐로드` 폴더 전체가 아니라 이 앱 폴더만 별도 저장소로 올리는 것을 권장합니다.

```bash
cd /Users/mingki/Desktop/AI/짐로드/짐로드_주간스케줄_관리도구
git init
git add .gitignore README.md DEPLOY.md index.html config.js 회원업로드_양식.csv supabase/schema.sql
git commit -m "Initial weekly scheduler app"
git branch -M main
git remote add origin https://github.com/GITHUB_ID/REPOSITORY_NAME.git
git push -u origin main
```

GitHub 저장소에서 Settings > Pages로 들어가 Source를 `Deploy from a branch`, Branch를 `main`, Folder를 `/root`로 선택합니다.

## 5. 첫 실데이터 이관

GitHub Pages 주소는 기존 로컬 파일 앱과 저장공간이 다릅니다. 처음 한 번은 실제 회원 데이터를 클라우드에 올려야 합니다.

1. 배포된 GitHub Pages 주소를 엽니다.
2. Google 또는 이메일로 로그인합니다.
3. 상단 `불러오기`로 `private/짐로드_실회원_초기데이터.private.json` 파일을 불러옵니다.
4. 클라우드 패널에서 `지금 저장`을 누릅니다.
5. 모바일에서 같은 주소로 접속하고 같은 계정으로 로그인하면 클라우드 데이터를 불러옵니다.

그 다음부터는 수정할 때마다 로컬 저장과 클라우드 저장이 같이 동작합니다.
