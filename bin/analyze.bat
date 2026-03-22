@echo off
cd /d "%~dp0"

for %%I in ("%~dp0..") do set ROOT_DIR=%%~fI\
set LOG_DIR=%ROOT_DIR%logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

set DATETIME=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set DATETIME=%DATETIME: =0%
set LOG_FILE=%LOG_DIR%\analyze_%DATETIME%.log

(
echo ==================================
echo ANALYSE SYSTEME
echo Date: %date% %time%
echo ==================================
) > "%LOG_FILE%"

echo Analyse systeme en cours...
echo.

:: Lancer SFC pour progression en direct
sfc /verifyonly

:: Parser le log CBS pour savoir s'il y a eu une violation
findstr /i /c:"La Protection des ressources Windows a detecte des violations de l'integrite" %windir%\Logs\CBS\CBS.log >nul 2>&1
if %errorlevel%==0 (
    echo Corruption detectee >> "%LOG_FILE%"
    echo Corruption detectee
) else (
    echo Aucune corruption detectee >> "%LOG_FILE%"
    echo Aucune corruption detectee
)

echo.
echo Analyse terminee
echo Log genere :
echo %LOG_FILE%
echo.
pause