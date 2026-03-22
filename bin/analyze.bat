@echo off
cd /d "%~dp0"

:: Dossier racine et logs
for %%I in ("%~dp0..") do set ROOT_DIR=%%~fI\
set LOG_DIR=%ROOT_DIR%logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: Timestamp et log
set DATETIME=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set DATETIME=%DATETIME: =0%
set LOG_FILE=%LOG_DIR%\analyze_%DATETIME%.log

:: Header log minimal
(
echo ==================================
echo ANALYSE SYSTEME
echo Date: %date% %time%
echo ==================================
) > "%LOG_FILE%"

:: UI
echo Analyse systeme en cours...
echo.

:: 1️⃣ Lancer SFC directement pour progression live
sfc /verifyonly

:: 2️⃣ Après fin SFC, log minimal selon code retour
set SFC_CODE=%errorlevel%
echo. >> "%LOG_FILE%"
echo ===== RESULTAT ANALYSE ===== >> "%LOG_FILE%"

if %SFC_CODE%==0 (
    echo Aucune corruption detectee >> "%LOG_FILE%"
    echo Aucune corruption detectee
) else (
    echo Corruption detectee ou action requise >> "%LOG_FILE%"
    echo Corruption detectee ou action requise
)

:: 3️⃣ Indiquer où trouver le log complet CBS si besoin
echo. >> "%LOG_FILE%"
echo Pour details, consulter le CBS log : %windir%\Logs\CBS\CBS.log >> "%LOG_FILE%"

echo.
echo Analyse terminee
echo Log genere :
echo %LOG_FILE%
echo.
pause