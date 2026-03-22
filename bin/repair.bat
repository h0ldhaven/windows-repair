@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: 1. On force la console en UTF-8 pour le Batch
chcp 65001 >nul
:: ------------------------------------

:: Dossier racine et logs
for %%I in ("%~dp0..") do set ROOT_DIR=%%~fI\
set LOG_DIR=%ROOT_DIR%logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
:: ------------------------------------

:: Timestamp et fichiers
set DATETIME=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set DATETIME=%DATETIME: =0%
set LOG_FILE=%LOG_DIR%\repair_%DATETIME%.log
set TEMP_LOG=%TEMP%\repair_temp.txt
:: ------------------------------------

:: Header log (On le fait en Batch simple pour éviter tout conflit)
echo ================================== > "%LOG_FILE%"
echo REPARATION SYSTEME >> "%LOG_FILE%"
echo Date: %date% %time% >> "%LOG_FILE%"
echo ================================== >> "%LOG_FILE%"
:: ------------------------------------

echo [1/2] DISM : Analyse et Réparation de l'image...

:: --- VÉRIFICATION CONNEXION ---
echo.
ping -n 1 8.8.8.8 >nul
if %errorlevel% neq 0 (
    set "NET_STAT=[!] ATTENTION : Pas de connexion Internet détectée (Mode Hors-ligne)."
    echo !NET_STAT!
) else (
    set "NET_STAT=[+] Connexion Internet OK (Utilisation de Windows Update)."
    echo !NET_STAT!
)

:: Écriture immédiate dans le log (UTF-8)
powershell -NoProfile -Command "'Status Réseau : %NET_STAT%', '' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append"
:: ------------------------------------

if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

:: Lancement DISM (Redirection standard)
start /b cmd /c "dism /online /cleanup-image /restorehealth > "%TEMP_LOG%" 2>&1"
:: ------------------------------------

:loop_dism
cls
echo [1/2] DISM : Analyse et Réparation de l'image...
echo.
if exist "%TEMP_LOG%" (
    :: On nettoie tout sauf les caractères 10 (Line Feed) et 13 (Carriage Return)
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "dism.exe" >nul
if %errorlevel% equ 0 goto loop_dism

:: Sauvegarde DISM (ANSI vers UTF8)
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"
:: ------------------------------------

:: ================================
:: [2/2] SFC
:: ================================
echo.
echo [2/2] SFC en cours...
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

start /b cmd /c "sfc /scannow > "%TEMP_LOG%" 2>&1"

:loop_sfc
cls
echo [1/2] DISM Termine.
echo [2/2] SFC en cours...
echo.
if exist "%TEMP_LOG%" (
    powershell -Command "$content = Get-Content -Path '%TEMP_LOG%' -Encoding Unicode -ErrorAction SilentlyContinue; if ($content) { $content | ForEach-Object { $c = $_ -replace '[\x00-\x1F]', ''; if ($c.Trim()) { Write-Host $c } } }"
)
timeout /t 3 >nul
tasklist | find /i "sfc.exe" >nul
if %errorlevel% equ 0 goto loop_sfc

:: Finalisation : On copie le contenu propre dans le log final
powershell -Command "Get-Content -Path '%TEMP_LOG%' -Encoding Unicode | ForEach-Object { $_ -replace '[\x00-\x1F]', '' } | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append"
:: ------------------------------------

:: On sauvegarde le résultat final
type "%TEMP_LOG%" >> "%LOG_FILE%"
del "%TEMP_LOG%" >nul 2>&1
:: ------------------------------------

echo.
echo REPARATION TERMINEE. Log: %LOG_FILE%
pause