@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: 1. On force la console en UTF-8 pour le Batch
chcp 65001 >nul

:: Dossier racine et logs
for %%I in ("%~dp0..") do set ROOT_DIR=%%~fI\
set LOG_DIR=%ROOT_DIR%logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: Timestamp et fichiers
set DATETIME=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set DATETIME=%DATETIME: =0%
set LOG_FILE=%LOG_DIR%\analyze_%DATETIME%.log
set TEMP_LOG=%TEMP%\sfc_temp.txt

:: Header log
(
echo ==================================
echo ANALYSE SYSTEME
echo Date: %date% %time%
echo ==================================
echo.
echo ===== DETAILS DE LA PROCEDURE =====
) > "%LOG_FILE%"

echo Analyse systeme en cours... (SFC /VERIFYONLY)
echo.2

:: ==== L'ASTUCE : REDIRECTION VERS FICHIER PUIS LECTURE LIVE ====
:: On lance SFC et on envoie sa sortie dans un fichier temporaire
:: Le ">" préserve mieux l'encodage que le "|"
start /b cmd /c "sfc /verifyonly > "%TEMP_LOG%" 2>&1"

:: Boucle de lecture "Live" du fichier temporaire
:loop
cls
echo Analyse systeme en cours... (SFC /VERIFYONLY)
echo.
if exist "%TEMP_LOG%" (
    :: On utilise PowerShell juste pour LIRE le fichier et le convertir proprement
    powershell -Command "$content = Get-Content -Path '%TEMP_LOG%' -Encoding Unicode -ErrorAction SilentlyContinue; if ($content) { $content | ForEach-Object { $c = $_ -replace '[\x00-\x1F]', ''; if ($c.Trim()) { Write-Host $c } } }"
)
timeout /t 2 >nul
tasklist | find /i "sfc.exe" >nul
if %errorlevel% equ 0 goto loop

:: Finalisation : On copie le contenu propre dans le log final
powershell -Command "Get-Content -Path '%TEMP_LOG%' -Encoding Unicode | ForEach-Object { $_ -replace '[\x00-\x1F]', '' } | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append"
del "%TEMP_LOG%" >nul 2>&1

echo.
echo ----------------------------------
echo Analyse terminee.
echo Log genere : "%LOG_FILE%"
pause