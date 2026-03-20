@echo off
title Outil de reparation Windows

:: ================================
:: CONFIG
:: ================================
set VERSION=1.0.0
set LOG_DIR=%~dp0logs

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

set DATETIME=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set DATETIME=%DATETIME: =0%

set LOG_FILE=%LOG_DIR%\repair_%DATETIME%.log

:: ================================
:: HEADER
:: ================================
(
echo ==============================================
echo OUTIL DE REPARATION WINDOWS
echo Version: %VERSION%
echo Date: %date% %time%
echo ==============================================
echo.
) > "%LOG_FILE%"

:: ================================
:: UI
:: ================================
color 0A
echo ==================================================
echo        OUTIL DE REPARATION WINDOWS
echo        Version %VERSION%
echo ==================================================
echo.
echo Merci de ne PAS fermer cette fenetre.
echo.

pause
cls

:: ================================
:: ETAPE 1 - DISM
:: ================================
echo [ETAPE 1/2] DISM en cours...

DISM /Online /Cleanup-Image /RestoreHealth

set DISM_CODE=%errorlevel%

echo [DISM] >> "%LOG_FILE%"

if %DISM_CODE% equ 0 (
    echo RESULTAT: OK >> "%LOG_FILE%"
) else (
    echo RESULTAT: ECHEC >> "%LOG_FILE%"
    echo CODE: %DISM_CODE% >> "%LOG_FILE%"
)

echo. >> "%LOG_FILE%"

pause
cls

:: ================================
:: ETAPE 2 - SFC
:: ================================
echo [ETAPE 2/2] SFC en cours...

sfc /scannow

set SFC_CODE=%errorlevel%

echo [SFC] >> "%LOG_FILE%"

if %SFC_CODE% equ 0 goto SFC_OK
if %SFC_CODE% equ 1 goto SFC_REPAIRED
if %SFC_CODE% equ 2 goto SFC_FAILED

goto SFC_UNKNOWN

:SFC_OK
echo RESULTAT: OK (aucune erreur) >> "%LOG_FILE%"
goto SFC_END

:SFC_REPAIRED
echo RESULTAT: OK (reparations effectuees) >> "%LOG_FILE%"
goto SFC_END

:SFC_FAILED
echo RESULTAT: ECHEC (reparations impossibles) >> "%LOG_FILE%"
goto SFC_END

:SFC_UNKNOWN
echo RESULTAT: INCONNU >> "%LOG_FILE%"
echo CODE: %SFC_CODE% >> "%LOG_FILE%"

:SFC_END
echo. >> "%LOG_FILE%"

:: ================================
:: FIN
:: ================================
(
echo ==============================================
echo FIN EXECUTION
echo ==============================================
) >> "%LOG_FILE%"

echo.
echo ==================================================
echo                TERMINE
echo ==================================================
echo.
echo Log disponible ici :
echo %LOG_FILE%
echo.

pause