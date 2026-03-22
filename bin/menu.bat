@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: Forcer console en UTF-8 pour les accents du menu
chcp 65001 >nul

title Repair Tool by h0ldhaven
color 0A

:MENU
cls
echo.
echo ===============================================
echo        WINDOWS 10 / 11 - REPAIR TOOL
echo ===============================================
echo   Auteur : h0ldhaven ^| Statut : Administrateur
echo  ===============================================
echo.
echo  [1] - Analyse système uniquement
echo  [2] - Réparation système uniquement
echo  [3] - Analyse + Réparation du système
echo.
echo  [L] - Ouvrir le dossier des Logs
echo  [N] - Nettoyer les anciens rapports (+7 jours)
echo  [X] - SUPPRIMER TOUS LES LOGS (Clean All)
echo.
echo  [0] - Quitter le programme
echo.
echo  -----------------------------------------------

choice /c 123LNX0 /n /m "Choisissez une option : "

:: Rappel : errorlevel se teste du plus grand au plus petit
if errorlevel 7 exit
if errorlevel 6 goto CLEAN_ALL_LOGS
if errorlevel 5 goto CLEAN_OLD
if errorlevel 4 goto OPEN_LOGS
if errorlevel 3 goto RUN_ALL
if errorlevel 2 goto RUN_REPAIR
if errorlevel 1 goto RUN_ANALYZE

:RUN_ANALYZE
if exist "analyze.bat" (
    call "analyze.bat"
) else (
    echo. & echo [!] Erreur : analyze.bat est introuvable dans %cd%
    pause
)
goto MENU

:RUN_REPAIR
if exist "repair.bat" (
    call "repair.bat"
) else (
    echo. & echo [!] Erreur : repair.bat est introuvable dans %cd%
    pause
)
goto MENU

:RUN_ALL
if exist "all.bat" (
    call "all.bat"
) else (
    :: Si all.bat n'existe pas, on peut enchaîner les deux autres manuellement
    echo [i] Lancement de la séquence complète...
    if exist "analyze.bat" call "analyze.bat"
    if exist "repair.bat" call "repair.bat"
)
goto MENU

:OPEN_LOGS
:: Petit bonus : ouvre directement le dossier logs dans l'explorateur
if exist "..\logs" (
    start explorer.exe "..\logs"
) else (
    echo. & echo [!] Aucun log n'a encore été généré.
    pause
)
goto MENU

:CLEAN_OLD
echo.
echo [i] Nettoyage des logs de plus de 7 jours...
if exist "..\logs" (
    :: Forfiles cherche les fichiers .log de plus de 7 jours et les supprime
    forfiles /p "..\logs" /m *.log /d -7 /c "cmd /c del /q @path" 2>nul
    echo [+] Nettoyage terminé.
) else (
    echo [!] Dossier logs introuvable.
)
timeout /t 3 >nul
goto MENU

:CLEAN_ALL_LOGS
echo.
echo [!] SUPPRESSION TOTALE DES LOGS EN COURS...
if exist "..\logs" (
    del /q "..\logs\*.log" 2>nul
    echo [+] Tous les fichiers .log ont été supprimés.
)
timeout /t 2 >nul
goto MENU