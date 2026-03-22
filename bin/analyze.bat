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

:: --- ÉTAPE 1 : DISM CHECKHEALTH ---
echo.
echo  [1/3] INITIALISATION : Vérification de l'intégrité rapide...
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

:: Lancement DISM
start /b cmd /c "dism /online /cleanup-image /checkhealth > "%TEMP_LOG%" 2>&1"

:loop_checkhealth
cls
echo.
echo  [1/3] INITIALISATION : Vérification de l'intégrité rapide...
echo.
echo  [i]   NOTE           : Analyse immédiate de l'état logique du magasin de composants.
echo.
if exist "%TEMP_LOG%" (
    :: On nettoie tout sauf les caractères 10 (Line Feed) et 13 (Carriage Return)
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "dism.exe" >nul
if %errorlevel% equ 0 goto loop_checkhealth

:: Sauvegarde DISM (ANSI vers UTF8)
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"
:: ------------------------------------


:: --- ÉTAPE 2 : DISM SCANHEALTH ---
echo  [2/3] SCANNER : Analyse structurelle approfondie (Deep Scan)...
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

:: Lancement DISM
start /b cmd /c "dism /online /cleanup-image /scanhealth > "%TEMP_LOG%" 2>&1"

:loop_scanhealth
cls
echo.
echo  [1/3] INITIALISATION : Terminé.
echo  [2/3] SCANNER        : Analyse structurelle approfondie (Deep Scan)...
echo.
echo  [i]   NOTE           : Cette opération sollicite le processeur et le disque.
if exist "%TEMP_LOG%" (
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "dism.exe" >nul
if %errorlevel% equ 0 goto loop_scanhealth

:: Sauvegarde ScanHealth
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ '--- RESULTAT DISM SCANHEALTH ---' | Out-File '%LOG_FILE%' -Encoding utf8 -Append; $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"

:: ------------------------------------

:: --- ÉTAPE 3 : SFC VERIFYONLY ---
echo.
echo  [3/3] AUDIT : Vérification de la signature des fichiers système...
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

:: Lancement SFC en mode vérification seule (ne répare rien)
start /b cmd /c "sfc /verifyonly > "%TEMP_LOG%" 2>&1"
:: ------------------------------------

:: ------------------------------------
:loop_sfc
cls
echo.
echo  [1/3] INITIALISATION   : Terminé.
echo  [2/3] SCANNER          : Terminé.
echo  [3/3] AUDIT            : Vérification de la signature des fichiers système...
echo.
echo  [i]   NOTE             : Consolidation de la base WinSxS et purge des packages obsolètes.
echo.
if exist "%TEMP_LOG%" (
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::Unicode); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 2 >nul
tasklist | find /i "sfc.exe" >nul
if %errorlevel% equ 0 goto loop_sfc
:: ------------------------------------

:: Sauvegarde des logs
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::Unicode); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ '--- RESULTAT SFC VERIFYONLY ---' | Out-File '%LOG_FILE%' -Encoding utf8 -Append; $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"
:: ------------------------------------

del "%TEMP_LOG%" >nul 2>&1

echo.
echo ----------------------------------
echo Analyse terminee.
echo Log généré : "%LOG_FILE%"

:: Fin du script
if "%1"=="--nested" exit /b

echo.
echo Opération terminée. Appuyez sur une touche pour revenir au menu.
pause >nul
exit /b