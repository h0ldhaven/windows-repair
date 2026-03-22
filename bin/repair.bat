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
echo ================================== >> "%LOG_FILE%"
echo REPARATION SYSTEME >> "%LOG_FILE%"
echo Date: %date% %time% >> "%LOG_FILE%"
echo ================================== >> "%LOG_FILE%"
:: ------------------------------------

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


:: --- ÉTAPE 1 : RESTOREHEALTH ---
echo.
echo  [1/3] RESTAURATION : Réparation du magasin de composants (Payloads)...
echo  [i]   NOTE         : Téléchargement et remplacement des fichiers sources corrompus.
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

:: Lancement DISM (Redirection standard)
start /b cmd /c "dism /online /cleanup-image /restorehealth > "%TEMP_LOG%" 2>&1"
:: ------------------------------------

:loop_restorehealth
cls
echo.
echo  [1/3] RESTAURATION : Réparation du magasin de composants (Payloads)...
echo.
echo  [i]   NOTE         : Téléchargement et remplacement des fichiers sources corrompus.
echo.
if exist "%TEMP_LOG%" (
    :: On nettoie tout sauf les caractères 10 (Line Feed) et 13 (Carriage Return)
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "dism.exe" >nul
if %errorlevel% equ 0 goto loop_restorehealth

:: Sauvegarde DISM (ANSI vers UTF8)
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"
:: ------------------------------------

:: --- ÉTAPE 2 : SFC SCANNOW ---
echo.
echo  [2/3] DÉPLOYEMENT  : Remplacement des fichiers système actifs...
echo.
echo  [i]   NOTE         : Application des correctifs sur les DLL et EXE du noyau Windows.
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

start /b cmd /c "sfc /scannow > "%TEMP_LOG%" 2>&1"

:loop_sfc
cls
echo.
echo  [1/3] RESTAURATION : Terminé.
echo  [2/3] DÉPLOYEMENT  : Remplacement des fichiers système actifs...
echo.
echo  [i]   NOTE         : Application des correctifs sur les DLL et EXE du noyau Windows.
echo.
if exist "%TEMP_LOG%" (
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::Unicode); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "sfc.exe" >nul
if %errorlevel% equ 0 goto loop_sfc

:: Sauvegarde SFC
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::Unicode); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ '--- RESULTAT SFC SCANNOW ---' | Out-File '%LOG_FILE%' -Encoding utf8 -Append; $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"
:: ------------------------------------

:: --- ÉTAPE 3 : COMPONENT CLEANUP ---
echo.
echo  [3/3] OPTIMISATION : Consolidation du magasin WinSxS (Cleanup)...
echo.
echo  [i]   NOTE         : Purge des packages obsolètes et réduction de l'empreinte disque.
echo.
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

start /b cmd /c "dism /online /cleanup-image /startcomponentcleanup > "%TEMP_LOG%" 2>&1"

:loop_startcomponentcleanup
cls
echo.
echo  [1/3] RESTAURATION         : Terminé.
echo  [2/3] DÉPLOYEMENT          : Terminé.
echo  [3/3] OPTIMISATION         : Indexation et purge du magasin WinSxS...
echo.
echo  [i]   NOTE                 : Réduction de l'empreinte disque par élimination des deltas
echo                               de mise à jour obsolètes (Superseded Packages).
echo.
if exist "%TEMP_LOG%" (
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "dism.exe" >nul
if %errorlevel% equ 0 goto loop_startcomponentcleanup

:: Sauvegarde Cleanup
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ '--- RESULTAT CLEANUP FINAL ---' | Out-File '%LOG_FILE%' -Encoding utf8 -Append; $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"

:: Nettoyage final
del "%TEMP_LOG%" >nul 2>&1

echo.
echo  =============================================================
echo  PROCESSUS DE MAINTENANCE TERMINÉ.
echo  Rapport d'intervention : %LOG_FILE%
echo  =============================================================

:: Gestion workflow
if "%1"=="--nested" exit /b

echo.
echo Appuyez sur une touche pour revenir au menu principal.
pause >nul
exit /b