@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: 1. On force la console en UTF-8 pour le Batch
chcp 65001 >nul

:: Configuration
for %%I in ("%~dp0..") do set ROOT_DIR=%%~fI\
set LOG_DIR=%ROOT_DIR%logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: Timestamp et fichiers
set DATETIME=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set DATETIME=%DATETIME: =0%
set LOG_FILE=%LOG_DIR%\analyze_%DATETIME%.log
set TEMP_LOG=%TEMP%\sfc_temp.txt

:: Initialisation du LOG
powershell -NoProfile -Command "'==================================', 'ANALYSE SYSTÈME SEULE', 'Date: %date% %time%', '==================================' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8"
:: ------------------------------------

:: --- VÉRIFICATION CONNEXION + LOG ---
ping -n 1 8.8.8.8 >nul
if %errorlevel% neq 0 (
    set "NET_STAT=[!] STATUT : Hors-ligne (DISM sera limité si une réparation est requise)."
) else (
    set "NET_STAT=[+] STATUT : Connecté (Prêt pour une réparation complète via Windows Update)."
)
echo %NET_STAT%
powershell -NoProfile -Command "'Info Réseau : %NET_STAT%', '' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append"
:: ------------------------------------

echo.
echo [1/1] SFC : Vérification de l'intégrité (Lecture seule)...
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

:: Lancement SFC en mode vérification seule (ne répare rien)
start /b cmd /c "sfc /verifyonly > "%TEMP_LOG%" 2>&1"
:: ------------------------------------

:: ------------------------------------
:loop_sfc
cls
echo.
echo ============================================================
echo           ANALYSE SYSTÈME EN COURS (VERIFY ONLY)
echo ============================================================
echo.
echo.
if exist "%TEMP_LOG%" (
    powershell -Command "$content = Get-Content -Path '%TEMP_LOG%' -Encoding Unicode -ErrorAction SilentlyContinue; if ($content) { $content | ForEach-Object { $c = $_ -replace '[\x00-\x1F]', ''; if ($c.Trim()) { Write-Host $c } } }"
)
timeout /t 2 >nul
tasklist | find /i "sfc.exe" >nul
if %errorlevel% equ 0 goto loop_sfc
:: ------------------------------------

:: Finalisation : On copie le contenu propre dans le log final
powershell -Command "Get-Content -Path '%TEMP_LOG%' -Encoding Unicode | ForEach-Object { $_ -replace '[\x00-\x1F]', '' } | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append"
:: ------------------------------------
del "%TEMP_LOG%" >nul 2>&1

echo.
echo ----------------------------------
echo Analyse terminee.
echo Log genere : "%LOG_FILE%"
pause