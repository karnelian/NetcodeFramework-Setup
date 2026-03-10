# NetcodeFramework Setup

Unity 멀티플레이어 게임 프로젝트를 원클릭으로 생성하는 자동화 스크립트.

## 사전 요구사항

- **Git** + **Git LFS**
- **GitHub CLI** (`winget install GitHub.cli`)

## 사용법

1. `setup.bat` 다운로드
2. 더블클릭으로 실행
3. 레포 이름 입력
4. 완료 후 Unity Hub에서 프로젝트 열기

## 자동 실행 내역

```
[1/7] GitHub 인증 확인 (미인증 시 브라우저 로그인)
[2/7] 템플릿으로 GitHub 레포 생성
[3/7] 로컬 클론
[4/7] Git LFS 설치
[5/7] .gitattributes LFS 규칙 활성화
[6/7] NetcodeFramework Core 서브모듈 추가
[7/7] Push
```

## Unity 열면 자동으로

1. **DependencyInstaller** — UGS 패키지 선택 설치
2. **FrameworkAssetGenerator** — Manager 프리팹 + Settings SO + 씬 자동 생성

## 관련 레포

- [NetcodeFramework-Template](https://github.com/karnelian/NetcodeFramework-Template) — GitHub Template
- [NetcodeFramework-Core](https://github.com/karnelian/NetcodeFramework-Core) — 프레임워크 서브모듈
