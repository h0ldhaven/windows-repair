@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: Initialisation du SCRIPT
call "%~dp0utils.bat" :INIT_LOG "analyze"
call "%~dp0utils.bat" :HEADER "ANALYSE SYSTÈME SEULE"
call "%~dp0utils.bat" :SKIP_LINE
set TEMP_LOG=%TEMP%\repair_temp.txt
:: ------------------------------------

:: --- VÉRIFICATION CONNEXION + LOG ---
call "%~dp0utils.bat" :CHECK_NET
:: ------------------------------------


:: --- ÉTAPE 1 : RESTOREHEALTH ---
echo.
echo  %F_B_YELLOW%[1/3] RESTAURATION : Réparation du magasin de composants (Payloads)...%CLR_RESET%
echo  %F_B_YELLOW%[i]   NOTE         : Téléchargement et remplacement des fichiers sources corrompus.%CLR_RESET%
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

:: Lancement DISM (Redirection standard)
start /b cmd /c "dism /online /cleanup-image /restorehealth > "%TEMP_LOG%" 2>&1"
:: ------------------------------------

:loop_restorehealth
cls
echo.
echo  %F_B_YELLOW%[1/3] RESTAURATION : Réparation du magasin de composants (Payloads)...%CLR_RESET%
echo.
echo  %F_B_YELLOW%[i]   NOTE         : Téléchargement et remplacement des fichiers sources corrompus.%CLR_RESET%
echo.
if exist "%TEMP_LOG%" (
    :: On nettoie tout sauf les caractères 10 (Line Feed) et 13 (Carriage Return)
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "dism.exe" >nul
if %errorlevel% equ 0 goto loop_restorehealth

:: Sauvegarde DISM (ANSI vers UTF8)
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"
:: ------------------------------------

:: --- ÉTAPE 2 : SFC SCANNOW ---
echo.
echo  %F_B_YELLOW%[2/3] DÉPLOYEMENT  : Remplacement des fichiers système actifs...%CLR_RESET%
echo.
echo  %F_B_YELLOW%[i]   NOTE         : Application des correctifs sur les DLL et EXE du noyau Windows.%CLR_RESET%
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

start /b cmd /c "sfc /scannow > "%TEMP_LOG%" 2>&1"

:loop_sfc
cls
echo.
echo  %F_B_GREEN%[1/3] RESTAURATION : Terminé.%CLR_RESET%
echo  %F_B_YELLOW%[2/3] DÉPLOYEMENT  : Remplacement des fichiers système actifs...%CLR_RESET%
echo.
echo  %F_B_YELLOW%[i]   NOTE         : Application des correctifs sur les DLL et EXE du noyau Windows.%CLR_RESET%
echo.
if exist "%TEMP_LOG%" (
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::Unicode); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "sfc.exe" >nul
if %errorlevel% equ 0 goto loop_sfc

:: Sauvegarde SFC
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::Unicode); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ '--- RESULTAT SFC SCANNOW ---' | Out-File '%LOG_FILE%' -Encoding utf8 -Append; $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"
:: ------------------------------------

:: --- ÉTAPE 3 : COMPONENT CLEANUP ---
echo.
echo  %F_B_YELLOW%[3/3] OPTIMISATION : Consolidation du magasin WinSxS (Cleanup)...%CLR_RESET%
echo.
echo  %F_B_YELLOW%[i]   NOTE         : Purge des packages obsolètes et réduction de l'empreinte disque.%CLR_RESET%
echo.
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

start /b cmd /c "dism /online /cleanup-image /startcomponentcleanup > "%TEMP_LOG%" 2>&1"

:loop_startcomponentcleanup
cls
echo.
echo  %F_B_GREEN%[1/3] RESTAURATION         : Terminé.%CLR_RESET%
echo  %F_B_GREEN%[2/3] DÉPLOYEMENT          : Terminé.%CLR_RESET%
echo  %F_B_YELLOW%[3/3] OPTIMISATION         : Indexation et purge du magasin WinSxS...%CLR_RESET%
echo.
echo  %F_B_YELLOW%[i]   NOTE                 : Réduction de l'empreinte disque par élimination des deltas%CLR_RESET%
echo                               de mise à jour obsolètes (Superseded Packages).
echo.
if exist "%TEMP_LOG%" (
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "dism.exe" >nul
if %errorlevel% equ 0 goto loop_startcomponentcleanup

:: Sauvegarde Cleanup
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ '--- RESULTAT CLEANUP FINAL ---' | Out-File '%LOG_FILE%' -Encoding utf8 -Append; $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"

:: Nettoyage final
del "%TEMP_LOG%" >nul 2>&1

echo.
echo  =============================================================
echo  PROCESSUS DE MAINTENANCE TERMINÉ.
echo  UN REDEMARRAGE DU SYSTEME EST RECOMMANDÉ.
echo  Rapport d'intervention : %LOG_FILE%
echo  =============================================================

:: Fin du script
:: On ferme la session proprement (nettoie les variables de la mémoire vive)
endlocal

if "%1"=="--nested" exit /b
echo.
echo  %F_B_GREEN%[FIN] Opération terminée.%CLR_RESET%
echo  Appuyez sur une touche pour revenir au menu.
pause >nul

:: On retourne au menu.bat
exit /b