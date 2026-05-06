@echo off

:: ==============================================================================
::      SYSTÈME D'AIGUILLAGE (ROUTAGE DES APPELS)
:: ==============================================================================
set "label=%~1"
set "label=%label::=%"

:: Vérification de l'existence de la fonction demandée
findstr /i "^:%label%" "%~f0" >nul || exit /b 1

:: Saut vers la fonction
goto :%label%

:: ==============================================================================
::      INITIALISATION ET VARIABLES SYSTÈME
:: ==============================================================================
:INIT_UTILS
:: 1. Force la console en UTF-8 (Support accents/symboles)
chcp 65001 >nul
:: 2. Définit les dossiers de base si absent (Héritage ou Indépendant)
if not defined ROOT_DIR (
    for %%I in ("%~dp0..") do set ROOT_DIR=%%~fI\
)
if not defined LOG_DIR (
    set LOG_DIR=%ROOT_DIR%logs
)
:: 3. Création du dossier de logs s'il n'existe pas
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
cls
exit /b

:: ==============================================================================
::      INITIALISATION DU FICHIER LOG (NOMMAGE AUTOMATIQUE)
:: ==============================================================================

:INIT_LOG
:: On s'assure que l'environnement (CHCP, Dossiers) est prêt
call :INIT_UTILS
:: 1. Recalcul du DATETIME formaté
set "temp_date=%date%"
set "temp_time=%time%"
set "DATETIME=%temp_date:~-4%-%temp_date:~3,2%-%temp_date:~0,2%_%temp_time:~0,2%-%temp_time:~3,2%-%temp_time:~6,2%"
set "DATETIME=%DATETIME: =0%"

:: 2. Construction du chemin complet du LOG
:: %~2 correspond au nom du module (ex: registry)
set "LOG_FILE=%LOG_DIR%\%~2_%DATETIME%.log"

:: 3. Création physique du fichier (Optionnel: avec une entête de session)
powershell -NoProfile -Command "'--- SESSION LOG : %~2 ---', 'Start: %DATETIME%', '--------------------------', '' | Out-File -FilePath "%LOG_FILE%" -Append -Encoding utf8"
exit /b


:: ==============================================================================
::      GESTION DE L'AFFICHAGE ET ESPACEMENT (FORMATAGE CONSOLE)
:: ==============================================================================

:SKIP_LINE
echo.
if defined LOG_FILE echo. >> "%LOG_FILE%"
exit /b

:SEPARATOR
echo %F_GRAY%  ------------------------------------------------------------------------------- %CLR_RESET%
if defined LOG_FILE echo  ------------------------------------------------------------------------------- >> "%LOG_FILE%"
exit /b

:: ==============================================================================
::      ENTÊTES DE SECTIONS (HEADERS)
:: ==============================================================================

:HEADER
:: 1. Vérification de sécurité pour le titre
if "%~2"=="" (set "TITLE=SANS_TITRE") else (set "TITLE=%~2")

:: 2. Affichage Console (Avec Date et Heure en gris pour la discrétion)
echo %F_CYAN%===============================================================================%CLR_RESET%
echo   %FX_BOLD%%TITLE%%CLR_RESET%
echo   %F_GRAY%Date: %date% %time%%CLR_RESET%
echo %F_CYAN%===============================================================================%CLR_RESET%

:: 3. Écriture Log (Uniquement si LOG_FILE est défini pour éviter les erreurs)
if defined LOG_FILE (
    powershell -NoProfile -Command "'==================================', '%TITLE%', 'Date: %date% %time%', '==================================' | Out-File -FilePath '%LOG_FILE%' -Append -Encoding utf8"
) else (
    :: Optionnel : Alerte si le log n'est pas configuré
    echo %F_RED%[!] Attention : LOG_FILE non defini. Passage en mode console seule.%CLR_RESET%
)
exit /b

:: ==============================================================================
::      DIAGNOSTIC RÉSEAU ET CONNECTIVITÉ
:: ==============================================================================

:CHECK_NET
:: 1. Test de ping (Google DNS)
ping -n 1 8.8.8.8 >nul 2>&1
set "NET_CODE=%ERRORLEVEL%"

:: 2. Détermination du message selon le résultat
if %NET_CODE% equ 0 (
    set "MSG= [+] Connexion Internet OK (Utilisation de Windows Update)."
    set "COLOR=%F_B_GREEN%"
) else (
    set "MSG= [-] ATTENTION : Pas de connexion Internet detectee (Mode Hors-ligne)."
    set "COLOR=%F_B_YELLOW%"
)

:: 3. Sortie Console et Log
echo %COLOR%%MSG%%CLR_RESET%
if defined LOG_FILE (
    powershell -NoProfile -Command "'Status Reseau : %MSG%', '' | Out-File -FilePath '%LOG_FILE%' -Append -Encoding utf8"
)
exit /b

:: ==============================================================================
::      MESSAGES D'ÉTAT (SUCCESS, ERROR, INFO)
:: ==============================================================================

:SUCCESS
:: Message de réussite (Vert)
echo %F_B_GREEN% [SUCCESS] %~2 %CLR_RESET%
if defined LOG_FILE (
    powershell -NoProfile -Command "' [SUCCESS] %~2' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append"
)
exit /b

:ERROR
:: Message d'erreur (Rouge)
echo %F_B_RED% [ERROR] %~2 %CLR_RESET%
if defined LOG_FILE (
    powershell -NoProfile -Command "' [ERROR] %~2' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append"
)
exit /b

:INFO
:: Message d'information ou de progression (Jaune)
echo %F_B_YELLOW% [INFO] %~2 %CLR_RESET%
if defined LOG_FILE (
    powershell -NoProfile -Command "' [INFO] %~2' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append"
)
exit /b

:: ==============================================================================
::      FIN DU FICHIER UTILS.BAT
:: ==============================================================================