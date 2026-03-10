@echo off
chcp 65001 >nul
title NetcodeFramework Project Setup

echo ============================================
echo   NetcodeFramework Project Setup
echo ============================================
echo.

:: ──────────────────────────────────────────────
:: Step 1: gh CLI 확인
:: ──────────────────────────────────────────────
where gh >nul 2>nul
if errorlevel 1 (
    echo [ERROR] gh CLI not found.
    echo Install: winget install GitHub.cli
    pause
    exit /b 1
)

:: ──────────────────────────────────────────────
:: Step 2: GitHub 인증 확인/실행
:: ──────────────────────────────────────────────
echo [1/7] Checking GitHub authentication...
gh auth status >nul 2>nul
if errorlevel 1 (
    echo   Not authenticated. Starting login...
    echo.
    gh auth login -p https -w
    if errorlevel 1 (
        echo [ERROR] Authentication failed.
        pause
        exit /b 1
    )
)
echo   Authenticated.

:: 인증된 username 자동 취득
for /f "delims=" %%i in ('gh api user -q .login 2^>nul') do set GITHUB_USER=%%i
if "%GITHUB_USER%"=="" (
    echo [ERROR] Could not get GitHub username.
    pause
    exit /b 1
)
echo   User: %GITHUB_USER%
echo.

:: ──────────────────────────────────────────────
:: Step 3: 프로젝트 설정 입력
:: ──────────────────────────────────────────────
set /p REPO_NAME="Repository Name: "
if "%REPO_NAME%"=="" (
    echo [ERROR] Repository name is required.
    pause
    exit /b 1
)

set /p VISIBILITY="Visibility (private/public, default: private): "
if "%VISIBILITY%"=="" set VISIBILITY=private

set /p CLONE_DIR="Clone Directory (default: C:\Project): "
if "%CLONE_DIR%"=="" set CLONE_DIR=C:\Project

echo.
echo ============================================
echo   Settings
echo ============================================
echo   User:       %GITHUB_USER%
echo   Repo:       %GITHUB_USER%/%REPO_NAME%
echo   Visibility: %VISIBILITY%
echo   Path:       %CLONE_DIR%\%REPO_NAME%
echo ============================================
echo.
set /p CONFIRM="Proceed? (Y/n): "
if /i "%CONFIRM%"=="n" (
    echo Cancelled.
    pause
    exit /b 0
)

:: ──────────────────────────────────────────────
:: Step 4: 템플릿으로 레포 생성
:: ──────────────────────────────────────────────
echo.
echo [2/7] Creating repository from template...
gh repo create %GITHUB_USER%/%REPO_NAME% --template karnelian/NetcodeFramework-Template --%VISIBILITY%
if errorlevel 1 (
    echo [ERROR] Repository creation failed.
    pause
    exit /b 1
)
echo   Created: %GITHUB_USER%/%REPO_NAME%

:: GitHub가 템플릿 복사 완료할 때까지 대기
echo   Waiting for GitHub to finish template copy...
timeout /t 5 /nobreak >nul

:: ──────────────────────────────────────────────
:: Step 5: 클론 + LFS
:: ──────────────────────────────────────────────
echo.
echo [3/7] Cloning repository...
if not exist "%CLONE_DIR%" mkdir "%CLONE_DIR%"
cd /d "%CLONE_DIR%"
git clone https://github.com/%GITHUB_USER%/%REPO_NAME%.git
if errorlevel 1 (
    echo [ERROR] Clone failed.
    pause
    exit /b 1
)
cd /d "%CLONE_DIR%\%REPO_NAME%"

echo.
echo [4/7] Setting up Git LFS...
git lfs install

echo.
echo [5/7] Activating LFS rules...
copy /y .gitattributes.template .gitattributes >nul
git add .gitattributes
git commit -m "Enable Git LFS rules"

:: ──────────────────────────────────────────────
:: Step 6: 서브모듈 추가
:: ──────────────────────────────────────────────
echo.
echo [6/7] Adding NetcodeFramework Core submodule...
git submodule add https://github.com/karnelian/NetcodeFramework-Core.git Assets/NetcodeFramework
if errorlevel 1 (
    echo [ERROR] Submodule add failed. Check access to NetcodeFramework-Core.
    pause
    exit /b 1
)
git commit -m "Add NetcodeFramework Core submodule"

:: ──────────────────────────────────────────────
:: Step 7: Push
:: ──────────────────────────────────────────────
echo.
echo [7/7] Pushing to remote...
git push

echo.
echo ============================================
echo   Setup Complete!
echo ============================================
echo   Repo: https://github.com/%GITHUB_USER%/%REPO_NAME%
echo   Path: %CLONE_DIR%\%REPO_NAME%
echo.
echo   Next: Open in Unity Hub
echo ============================================
pause
