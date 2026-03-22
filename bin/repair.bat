@echo off
cd /d "%~dp0"

:: ================================
:: Dossier racine et logs
:: ================================
for %%I in ("%~dp0..") do set ROOT_DIR=%%~fI\
set LOG_DIR=%ROOT_DIR%logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: Timestamp pour le log
set DATETIME=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set DATETIME=%DATETIME: =0%
set LOG_FILE=%LOG_DIR%\repair_%DATETIME%.log

:: ================================
:: Header log
:: ================================
(
echo ==================================
echo REPARATION SYSTEME
echo Date: %date% %time%
echo ==================================
) > "%LOG_FILE%"

:: ================================
:: UI
:: ================================
echo ============================================================
echo                  REPARATION SYSTEME
echo ============================================================
echo.

:: ================================
:: DISM
:: ================================
echo [1/2] DISM en cours...
echo.

set /a MAX_WAIT=300
set /a ELAPSED=0

:: Lance DISM dans une fenêtre de fond
start "" /b cmd /c "DISM /Online /Cleanup-Image /RestoreHealth"

:WAIT_DISM
:: Vérifie si un processus DISM est encore actif
tasklist /fi "imagename eq dism.exe" | find /i "dism.exe" >nul
if errorlevel 1 goto DISM_DONE

:: Attendre 5 secondes et incrémenter le timer
timeout /t 5 /nobreak >nul
set /a ELAPSED+=5
if %ELAPSED% GEQ %MAX_WAIT% (
    echo DISM a depasse 5 minutes, on skip >> "%LOG_FILE%"
    echo DISM a depasse 5 minutes, on skip
    taskkill /im dism.exe /f >nul 2>&1
    goto DISM_DONE
)
goto WAIT_DISM

:DISM_DONE
echo DISM termine >> "%LOG_FILE%"
echo DISM termine

:: ================================
:: SFC
:: ================================
echo.
echo [2/2] SFC en cours...
echo.

sfc /scannow
set SFC_CODE=%ERRORLEVEL%
if %SFC_CODE%==0 (
    echo SFC: OK >> "%LOG_FILE%"
    echo SFC termine: OK
) else (
    echo SFC: ERREUR >> "%LOG_FILE%"
    echo SFC a rencontre un probleme
)

:: ================================
:: FIN
:: ================================
echo.
echo ============================================================
echo                   REPARATION TERMINEE
echo ============================================================
echo Log: %LOG_FILE%
echo.

pause