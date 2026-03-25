@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: Configuration des dossiers
for %%I in ("%~dp0..") do set ROOT_DIR=%%~fI\
set LOG_DIR=%ROOT_DIR%logs
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: 1. Nom de log unique
set DATETIME=%date:~-4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%
set DATETIME=%DATETIME: =0%
set FULL_LOG=%LOG_DIR%\full_repair_%DATETIME%.log

:: 2. Header (Affichage console ET écriture log)
echo ============================================================
echo           LANCEMENT DE LA RÉPARATION COMPLÈTE
echo ============================================================
echo.

(
echo ============================================================
echo           RAPPORT DE MAINTENANCE COMPLÈTE
echo           Date : %date% %time%
echo ============================================================
echo.
) > "%FULL_LOG%"

:: 3. ÉTAPE 1 : ANALYSE
echo [+] ÉTAPE 1 : ANALYSE EN COURS...
echo [+] ÉTAPE 1 : ANALYSE >> "%FULL_LOG%"

call "%~dp0analyze.bat" --nested

:: On cherche le log d'analyse le plus récent pour l'inclure
for /f "delims=" %%F in ('dir /b /od "%LOG_DIR%\analyze_*.log"') do set LAST_ANALYZE=%%F
if defined LAST_ANALYZE (
    echo [i] Fusion du rapport d'analyse...
    echo. >> "%FULL_LOG%"
    echo --- CONTENU DE L'ANALYSE --- >> "%FULL_LOG%"
    type "%LOG_DIR%\%LAST_ANALYZE%" >> "%FULL_LOG%"
    echo. >> "%FULL_LOG%"
)

:: 4. ÉTAPE 2 : RÉPARATION
echo.
echo [+] ÉTAPE 2 : RÉPARATION EN COURS...
echo [+] ÉTAPE 2 : RÉPARATION >> "%FULL_LOG%"

call "%~dp0repair.bat" --nested

:: On cherche le log de réparation le plus récent pour l'inclure
for /f "delims=" %%F in ('dir /b /od "%LOG_DIR%\repair_*.log"') do set LAST_REPAIR=%%F
if defined LAST_REPAIR (
    echo [i] Fusion du rapport de réparation...
    echo. >> "%FULL_LOG%"
    echo --- CONTENU DE LA RÉPARATION --- >> "%FULL_LOG%"
    type "%LOG_DIR%\%LAST_REPAIR%" >> "%FULL_LOG%"
    echo. >> "%FULL_LOG%"
)

:: 5. Finalisation
echo.
echo ============================================================
echo           TOUTES LES OPÉRATIONS SONT TERMINÉES
echo ============================================================
echo Rapport consolidé disponible : %FULL_LOG%

(
echo.
echo ============================================================
echo           FIN DES OPÉRATIONS : %date% %time%
echo ============================================================
) >> "%FULL_LOG%"

:: Fin du script
:: On ferme la session proprement (nettoie les variables de la mémoire vive)
endlocal

echo.
echo  %F_B_GREEN%[FIN] TOUTES LES OPÉRATIONS SONT TERMINÉES.%CLR_RESET%
echo  Appuyez sur une touche pour revenir au menu.
pause >nul

:: On retourne au menu.bat
exit /b