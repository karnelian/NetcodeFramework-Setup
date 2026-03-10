@echo off
chcp 65001 >nul
title NetcodeFramework Project Setup
echo ============================================
echo   NetcodeFramework Project Setup v1.0
echo ============================================
echo.

:: Check gh CLI
where gh >nul 2>nul
if errorlevel 1 (
    echo [ERROR] gh CLI not found.
    echo Install: winget install GitHub.cli
    pause
    exit /b 1
)

:: Check GitHub auth
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

:: Get username
for /f "delims=" %%i in ('gh api user -q .login 2^>nul') do set GITHUB_USER=%%i
if "%GITHUB_USER%"=="" (
    echo [ERROR] Could not get GitHub username.
    pause
    exit /b 1
)
echo   User: %GITHUB_USER%
echo.

:: Input settings
set /p REPO_NAME="Repository Name: "
if "%REPO_NAME%"=="" (
    echo [ERROR] Repository name is required.
    pause
    exit /b 1
)

set /p VISIBILITY="Visibility - private or public (default: private): "
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

:: Create repo from template
echo.
echo [2/7] Creating repository from template...
gh repo create %GITHUB_USER%/%REPO_NAME% --template karnelian/NetcodeFramework-Template --%VISIBILITY%
if errorlevel 1 (
    echo [ERROR] Repository creation failed.
    pause
    exit /b 1
)
echo   Created: %GITHUB_USER%/%REPO_NAME%
echo   Waiting for GitHub...
timeout /t 5 /nobreak >nul

:: Clone
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

:: LFS
echo.
echo [4/7] Setting up Git LFS...
git lfs install

:: Activate gitattributes
echo.
echo [5/7] Activating LFS rules...
copy /y .gitattributes.template .gitattributes >nul
git add .gitattributes
git commit -m "Enable Git LFS rules"

:: Submodule
echo.
echo [6/7] Adding NetcodeFramework Core submodule...
git submodule add https://github.com/karnelian/NetcodeFramework-Core.git Assets/NetcodeFramework
if errorlevel 1 (
    echo [ERROR] Submodule add failed.
    pause
    exit /b 1
)
git commit -m "Add NetcodeFramework Core submodule"

:: Push
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
