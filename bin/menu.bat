@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: 1. CONFIGURATION DE LA FENÊTRE (Largeur=70, Hauteur=32)
mode con: cols=110 lines=60

:: CHARGEMENT DU THÈME
if exist "theme.bat" (
    call "theme.bat"
) else if exist "bin\theme.bat" (
    call "bin\theme.bat"
)

:: CHARGEMENT DES UTILS
if exist "utils.bat" (
    call "utils.bat"
) else if exist "bin\utils.bat" (
    call "bin\utils.bat"
)

:: Forcer console en UTF-8 pour les accents du menu
chcp 65001 >nul

title Windows Tool by h0ldhaven

:MENU
cls
:: --- ENTETE ASCII SECURISE ---
echo.
echo  ---------------------------------------------------------
echo.
echo  %F_CYAN% $$\      $$\ $$$$$$\ $$\   $$\ $$$$$$$\   $$$$$$\  $$\      $$\  $$$$$$\  %CLR_RESET%
echo  %F_CYAN% $$ ^| $\  $$ ^|\_$$  _^|$$$\  $$ ^|$$  __$$\ $$  __$$\ $$ ^| $\  $$ ^|$$  __$$\ %CLR_RESET%
echo  %F_CYAN% $$ ^|$$$\ $$ ^|  $$ ^|  $$$$\ $$ ^|$$ ^|  $$ ^|$$ /  $$ ^|$$ ^|$$$\ $$ ^|$$ /  \__^|%CLR_RESET%
echo  %F_CYAN% $$ $$ $$\$$ ^|  $$ ^|  $$ $$\$$ ^|$$ ^|  $$ ^|$$ ^|  $$ ^|$$ $$ $$\$$ ^|\$$$$$$\  %CLR_RESET%
echo  %F_CYAN% $$$$  _$$$$ ^|  $$ ^|  $$ \$$$$ ^|$$ ^|  $$ ^|$$ ^|  $$ ^|$$$$  _$$$$ ^| \____$$\ %CLR_RESET%
echo  %F_CYAN% $$$  / \$$$ ^|  $$ ^|  $$ ^|\$$$ ^|$$ ^|  $$ ^|$$ ^|  $$ ^|$$$  / \$$$ ^|$$\   $$ ^|%CLR_RESET%
echo  %F_CYAN% $$  /   \$$ ^|$$$$$$\ $$ ^| \$$ ^|$$$$$$$  ^| $$$$$$  ^|$$  /   \$$ ^|\$$$$$$  ^|%CLR_RESET%
echo  %F_CYAN% \__/     \__^|\______^|\__^|  \__^|\_______/  \______/ \__/     \__^| \______/ %CLR_RESET%
echo.
echo  %F_CYAN%           $$$$$$$$\  $$$$$$\   $$$$$$\  $$\       %CLR_RESET%
echo  %F_CYAN%           \__$$  __^|$$  __$$\ $$  __$$\ $$ ^|      %CLR_RESET%
echo  %F_CYAN%              $$ ^|   $$ /  $$ ^|$$ /  $$ ^|$$ ^|      %CLR_RESET%
echo  %F_CYAN%              $$ ^|   $$ ^|  $$ ^|$$ ^|  $$ ^|$$ ^|      %CLR_RESET%
echo  %F_CYAN%              $$ ^|   $$ ^|  $$ ^|$$ ^|  $$ ^|$$ ^|      %CLR_RESET%
echo  %F_CYAN%              $$ ^|   $$ ^|  $$ ^|$$ ^|  $$ ^|$$ ^|      %CLR_RESET%
echo  %F_CYAN%              $$ ^|    $$$$$$  ^| $$$$$$  ^|$$$$$$$$\ %CLR_RESET%
echo  %F_CYAN%              \__^|    \______/  \______/ \________^| %CLR_RESET%
echo.
echo  %F_WHITE%By %F_RED%h0ldhaven%CLR_RESET%
echo  ---------------------------------------------------------
echo.
echo  Appuyez sur la touche correspondante pour lancer le programme :
echo.
echo  %FX_BOLD%%FX_UNDER%SYSTÈME%CLR_RESET% :
echo.
echo   %F_CYAN%[1]%CLR_RESET% - Analyse système uniquement
echo   %F_CYAN%[2]%CLR_RESET% - Réparation système uniquement
echo   %F_CYAN%[3]%CLR_RESET% - Réparation des registres système
echo   %F_CYAN%[4]%CLR_RESET% - Analyse + Réparation complète %F_GREEN%(Recommandé)%CLR_RESET%
echo.
echo  %FX_BOLD%%FX_UNDER%LOGS%CLR_RESET% :
echo.
echo   %F_YELLOW%[L]%CLR_RESET% - Ouvrir le dossier des Logs
echo   %F_YELLOW%[N]%CLR_RESET% - Nettoyer les rapports anciens (+7 jours)
echo   %F_RED%[X]%CLR_RESET% - %FX_BOLD%SUPPRIMER TOUS LES LOGS%CLR_RESET%
echo.
echo  %FX_BOLD%%FX_UNDER%REGISTRES%CLR_RESET% :
echo.
echo   %F_YELLOW%[R]%CLR_RESET% - Ouvrir le dossier des Registres
echo   %F_RED%[T]%CLR_RESET% - %FX_BOLD%SUPPRIMER TOUTES LES SAUVEGARDES%CLR_RESET%
echo.
echo  %FX_BOLD%%FX_UNDER%AUTRES%CLR_RESET% :
echo.
echo   %F_RED%[0]%CLR_RESET% - Quitter le programme%CLR_RESET%
echo.
echo  %F_CYAN%───────────────────────────────────────────────────────────%CLR_RESET%

choice /c 1234LNXRT0 /n /m "  Choisissez une option : "

:: Rappel : errorlevel se teste du plus grand au plus petit
if errorlevel 10 goto EXIT_MENU
if errorlevel 9 goto CLEAN_REGISTRY_SAVES
if errorlevel 8 goto OPEN_REGISTRY
if errorlevel 7 goto CLEAN_ALL_LOGS
if errorlevel 6 goto CLEAN_OLD
if errorlevel 5 goto OPEN_LOGS
if errorlevel 4 goto RUN_ALL
if errorlevel 3 goto REPAIR_REGISTRY
if errorlevel 2 goto RUN_REPAIR
if errorlevel 1 goto RUN_ANALYZE

:RUN_ANALYZE
if exist "analyze.bat" (
    call "analyze.bat"
) else (
    cls
    echo. & echo %F_RED%[-] Erreur : analyze.bat est introuvable dans %cd% %CLR_RESET%
    pause
)
goto MENU

:RUN_REPAIR
if exist "repair.bat" (
    call "repair.bat"
) else (
    cls
    echo. & echo %F_RED%[-] Erreur : repair.bat est introuvable dans %cd% %CLR_RESET%
    pause
)
goto MENU

:REPAIR_REGISTRY
if exist "registry_fix.bat" (
    call "registry_fix.bat"
) else (
    cls
    echo. & echo %F_RED%[-] Erreur : registry_fix.bat est introuvable dans %cd% %CLR_RESET%
    pause
)
goto MENU

:RUN_ALL
if exist "all.bat" (
    call "all.bat"
) else (
    cls
    echo %F_YELLOW%[i] Lancement de la séquence complète...%CLR_RESET%
    if exist "analyze.bat" call "analyze.bat"
    if exist "repair.bat" call "repair.bat"
)
goto MENU

:OPEN_LOGS
cls & echo.
echo  %F_YELLOW%[i] Ouverture du répertoire logs..%CLR_RESET%
if exist "..\logs" (
    start explorer.exe "..\logs"
) else (
    echo. & echo %F_RED%[-] Aucun log n'a encore été généré.%CLR_RESET%
    pause
)
goto MENU

:CLEAN_OLD
cls & echo.
echo %F_YELLOW%[i] Nettoyage des logs de plus de 7 jours...%CLR_RESET%
if exist "..\logs" (
    :: Forfiles cherche les fichiers .log de plus de 7 jours et les supprime
    forfiles /p "..\logs" /m *.log /d -7 /c "cmd /c del /q @path" 2>nul
    echo  %F_GREEN%[+] Nettoyage terminé.%CLR_RESET%
) else (
    echo  %F_RED%[-] Dossier logs introuvable.%CLR_RESET%
)
timeout /t 3 >nul
goto MENU

:CLEAN_ALL_LOGS
cls & echo.
echo  %FX_BOLD%%F_RED%[!] SUPPRESSION TOTALE DES LOGS EN COURS...%CLR_RESET%
if exist "..\logs" (
    del /q "..\logs\*.log" 2>nul
    echo  %F_GREEN%[+] Tous les fichiers .log ont été supprimés.%CLR_RESET%
)
timeout /t 2 >nul
goto MENU

:OPEN_REGISTRY
if exist "..\reg" (
    cls
    echo. & echo  %F_YELLOW%[i] Ouverture du répertoire reg..%CLR_RESET%
    start explorer.exe "..\reg"
) else (
    cls
    echo. & echo  %F_RED%[-] Aucun backup registres n'a encore été généré.%CLR_RESET%
    pause
)
goto MENU

:CLEAN_REGISTRY_SAVES
cls
echo.
echo  %FX_BOLD%%F_RED%[!] SUPPRESSION TOTALE DES SAVES REGISTRES EN COURS...%CLR_RESET%
if exist "..\reg" (
    del /q "..\reg\*.reg" 2>nul
    echo  %F_GREEN%[+] Tous les fichiers .reg ont été supprimés.%CLR_RESET%
)
timeout /t 2 >nul
goto MENU

:EXIT_MENU
echo Nettoyage de la session...
taskkill /f /im powershell.exe /fi "WINDOWTITLE eq %TITLE%*" >nul 2>&1
endlocal
exit