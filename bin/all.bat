@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

call "%~dp0utils.bat" :INIT_LOG "full_repair"
call "%~dp0utils.bat" :HEADER "RÉPARATION COMPLÈTE"
call "%~dp0utils.bat" :SKIP_LINE

:: 3. ÉTAPE 1 : ANALYSE
echo %F_B_YELLOW%[+] ÉTAPE 1 : ANALYSE EN COURS...%CLR_RESET%
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
echo %F_B_YELLOW%[+] ÉTAPE 2 : RÉPARATION EN COURS...%CLR_RESET%
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