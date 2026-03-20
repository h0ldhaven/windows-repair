@echo off
title Outil de reparation Windows

:: ================================
:: CONFIG
:: ================================
set VERSION=1.0.0
set LOG_DIR=%~dp0logs

:: Création dossier logs si inexistant
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: Format date/heure safe (important)
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do (
    set DAY=%%a
    set MONTH=%%b
    set YEAR=%%c
)

for /f "tokens=1-3 delims=:." %%a in ("%time%") do (
    set HOUR=%%a
    set MIN=%%b
    set SEC=%%c
)

set LOG_FILE=%LOG_DIR%\repair_%YEAR%-%MONTH%-%DAY%_%HOUR%-%MIN%-%SEC%.log

:: ================================
:: HEADER LOG
:: ================================
echo ============================================== > "%LOG_FILE%"
echo   OUTIL DE REPARATION WINDOWS >> "%LOG_FILE%"
echo   Version: %VERSION% >> "%LOG_FILE%"
echo   Date: %date% %time% >> "%LOG_FILE%"
echo ============================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

:: ================================
:: UI
:: ================================
color 0A
echo ==================================================
echo        OUTIL DE REPARATION WINDOWS
echo        Version %VERSION%
echo ==================================================
echo.
echo Un log sera genere ici :
echo %LOG_FILE%
echo.
echo Merci de ne PAS fermer cette fenetre.
echo.

pause
cls

:: ================================
:: ETAPE 1 - DISM
:: ================================
echo [ETAPE 1/2] DISM en cours...
echo [ETAPE 1] DISM START >> "%LOG_FILE%"

DISM /Online /Cleanup-Image /RestoreHealth >> "%LOG_FILE%" 2>&1

if %errorlevel% neq 0 (
    echo [ERREUR] DISM code: %errorlevel%
    echo [ERREUR] DISM code: %errorlevel% >> "%LOG_FILE%"
) else (
    echo [OK] DISM termine
    echo [OK] DISM termine >> "%LOG_FILE%"
)

echo. >> "%LOG_FILE%"
pause
cls

:: ================================
:: ETAPE 2 - SFC
:: ================================
echo [ETAPE 2/2] SFC en cours...
echo [ETAPE 2] SFC START >> "%LOG_FILE%"

sfc /scannow >> "%LOG_FILE%" 2>&1

if %errorlevel% neq 0 (
    echo [ATTENTION] SFC code: %errorlevel%
    echo [ATTENTION] SFC code: %errorlevel% >> "%LOG_FILE%"
) else (
    echo [OK] SFC termine
    echo [OK] SFC termine >> "%LOG_FILE%"
)

echo. >> "%LOG_FILE%"

:: ================================
:: FIN
:: ================================
echo ============================================== >> "%LOG_FILE%"
echo   FIN EXECUTION >> "%LOG_FILE%"
echo ============================================== >> "%LOG_FILE%"

echo.
echo ==================================================
echo                TERMINE
echo ==================================================
echo.
echo Log disponible ici :
echo %LOG_FILE%
echo.
echo Pensez a redemarrer votre PC.
echo.

pause