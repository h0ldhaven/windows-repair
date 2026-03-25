@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

call "%~dp0utils.bat" :INIT_LOG "registry"

set REG_DIR=%ROOT_DIR%reg
if not exist "%REG_DIR%" mkdir "%REG_DIR%"

:: Initialisation du LOG
call "%~dp0utils.bat" :HEADER "MAINTENANCE DES REGISTRE WINDOWS"
call "%~dp0utils.bat" :SKIP_LINE

:: --- VÉRIFICATION CONNEXION + LOG ---
call "%~dp0utils.bat" :CHECK_NET
:: ------------------------------------

:: --- ÉTAPE 1 : BACKUP ---
echo.
:: log that we start backup
echo  [1/4] SAUVEGARDE : Backup des registres... >> "%LOG_FILE%"
echo  [1/4] SAUVEGARDE : Backup des registres...
call "%~dp0utils.bat" :SKIP_LINE

call "%~dp0utils.bat" :INFO "Sauvegarde des registres en cours.."

:: Définition du nom de fichier
set "BACKUP_FILE=%REG_DIR%\backup_sys_%DATETIME%.reg"

:: Exécution de l'export
reg export HKLM\SYSTEM "%BACKUP_FILE%" /y >nul 2>&1

:: Récupération de la taille (0 si le fichier n'existe pas)
set "FILE_SIZE=0"
if exist "%BACKUP_FILE%" (
    for %%A in ("%BACKUP_FILE%") do set "FILE_SIZE=%%~zA"
)

:: --- LOGIQUE DE DÉCISION ---
if %FILE_SIZE% gtr 0 (
    :: CAS SUCCÈS : On affiche le succès et on CONTINUE
    call "%~dp0utils.bat" :SUCCESS "Sauvegarde reussie : %BACKUP_FILE% (%FILE_SIZE% octets)"
    echo  [1/4] SAUVEGARDE : Termine. >> "%LOG_FILE%"
    echo  %F_GREEN%[1/4] SAUVEGARDE : Termine.%CLR_RESET%
) else (
    :: CAS ÉCHEC : On affiche l'erreur et on DEMANDE confirmation
    call "%~dp0utils.bat" :ERROR "ECHEC de la sauvegarde (Fichier absent ou vide)."
    echo  [1/4] SAUVEGARDE : ERREUR >> "%LOG_FILE%"
    
    echo %F_B_YELLOW% ! ATTENTION ! Le registre n'est pas protege. %CLR_RESET%
    set /p "user_abort=Voulez-vous vraiment continuer SANS sauvegarde ? (O/N) : "
    
    if /i "!user_abort!" NEQ "O" (
        call "%~dp0utils.bat" :INFO "Operation annulee par l'utilisateur."
        exit /b
    )
)

call "%~dp0utils.bat" :SKIP_LINE

:: --- ÉTAPE 2 : SCAN ---
:: log of step 2/4 started
echo  [2/4] SCAN       : Vérification des ruches et Backup... >> "%LOG_FILE%"
echo  [2/4] SCAN       : Vérification des ruches et Backup...
call "%~dp0utils.bat" :SKIP_LINE

set "RUCHES=HKLM\SYSTEM HKLM\SOFTWARE HKLM\SAM HKLM\SECURITY"

:: On boucle et on envoie chaque ruche vers une sous-routine
for %%R in (%RUCHES%) do (
    call :CHECK_RUCHE "%%R"
)

:: On saute la sous-routine pour continuer le script
goto :STEP2

:CHECK_RUCHE
set "RUCHE=%~1"
reg query "%RUCHE%" >nul 2>&1
if !errorlevel! equ 0 goto :RUCHE_OK

:: Si on est ici, c'est qu'il y a une erreur de lecture
if "%RUCHE%"=="HKLM\SECURITY" goto :RUCHE_PROTECTED
if "%RUCHE%"=="HKLM\SAM"      goto :RUCHE_PROTECTED

:RUCHE_PROTECTED
echo  %F_YELLOW%[+] %RUCHE% : OK (Protégée par le Système)%CLR_RESET%
echo  [+] %RUCHE% : OK (Protégée par le Système) >> "%LOG_FILE%"
exit /b

:RUCHE_ERROR
echo  %F_RED%[-] %RUCHE% : ERREUR (Corruption potentielle)%CLR_RESET%
echo  [-] %RUCHE% : ERREUR (Corruption potentielle) >> "%LOG_FILE%"
exit /b

:RUCHE_OK
echo  %F_GREEN%[+] %RUCHE% : OK%CLR_RESET%
echo  [+] %RUCHE% : OK >> "%LOG_FILE%"
exit /b

:STEP2
call "%~dp0utils.bat" :SKIP_LINE
echo.
echo  [2/4] SCAN       : Terminé. >> "%LOG_FILE%"
echo  [2/4] SCAN       : Terminé.
call "%~dp0utils.bat" :SKIP_LINE

:: --- ÉTAPE 3 : LODCTR ---
echo  [3/4] RÉPARATION : Compteurs de performance... >> "%LOG_FILE%"
echo  [3/4] RÉPARATION : Compteurs de performance...
call "%~dp0utils.bat" :SKIP_LINE

:: Exécution silencieuse
lodctr /R >nul 2>&1

:: Ecriture manuelle du succès (Propre et sans accents cassés)
if %errorlevel% equ 0 (
    echo  [+] Succès : Compteurs reconstruits. >> "%LOG_FILE%"
    echo %F_GREEN% [+] Succès : Compteurs reconstruits.%CLR_RESET%
)
call "%~dp0utils.bat" :SKIP_LINE

echo.
echo  [3/4] RÉPARATION : Terminé. >> "%LOG_FILE%"
echo  [3/4] RÉPARATION : Terminé.
call "%~dp0utils.bat" :SKIP_LINE

:: --- ÉTAPE 4 : AUDIT VIA POWERSHELL (Le fichier séparé) ---
echo.
echo  [4/4] AUDIT      : Recherche de services corrompus... >> "%LOG_FILE%"
echo  [4/4] AUDIT      : Recherche de services corrompus...
call "%~dp0utils.bat" :SKIP_LINE

if exist "%~dp0registry_audit.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0registry_audit.ps1" -tempDir "%TEMP%" -logFile "%LOG_FILE%"
) else (
    echo [!] Erreur : registry_audit.ps1 introuvable dans %~dp0
)

echo.
echo  [4/4] AUDIT      : Terminé.
echo. >> "%LOG_FILE%"
echo  [4/4] AUDIT      : Terminé. >> "%LOG_FILE%"
call "%~dp0utils.bat" :SKIP_LINE

echo.
echo  =============================================================
echo  MAINTENANCE TERMINÉE. Log : %LOG_FILE%
echo  =============================================================

call "%~dp0utils.bat" :SKIP_LINE
echo  ============================================================= >> "%LOG_FILE%"
echo  MAINTENANCE TERMINÉE. Log : %LOG_FILE% >> "%LOG_FILE%"
echo  ============================================================= >> "%LOG_FILE%"
call "%~dp0utils.bat" :SEPARATOR

pause
exit /b