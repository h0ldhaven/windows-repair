@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

:: Initialisation du SCRIPT
call "%~dp0utils.bat" :INIT_LOG "analyze"
call "%~dp0utils.bat" :HEADER "ANALYSE SYSTÈME SEULE"
call "%~dp0utils.bat" :SKIP_LINE
set TEMP_LOG=%TEMP%\sfc_temp.txt
:: ------------------------------------

:: --- VÉRIFICATION CONNEXION + LOG ---
call "%~dp0utils.bat" :CHECK_NET
:: ------------------------------------

:: --- ÉTAPE 1 : DISM CHECKHEALTH ---
echo.
echo  [1/3] INITIALISATION : Vérification de l'intégrité rapide...
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

:: Lancement DISM
start /b cmd /c "dism /online /cleanup-image /checkhealth > "%TEMP_LOG%" 2>&1"

:loop_checkhealth
cls
echo.
echo  %F_B_YELLOW%[1/3] INITIALISATION : Vérification de l'intégrité rapide...%CLR_RESET%
echo.
echo  %F_B_YELLOW%[i]   NOTE           : Analyse immédiate de l'état logique du magasin de composants.%CLR_RESET%
echo.
if exist "%TEMP_LOG%" (
    :: On nettoie tout sauf les caractères 10 (Line Feed) et 13 (Carriage Return)
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "dism.exe" >nul
if %errorlevel% equ 0 goto loop_checkhealth

:: Sauvegarde DISM (ANSI vers UTF8)
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"
:: ------------------------------------


:: --- ÉTAPE 2 : DISM SCANHEALTH ---
echo  [2/3] SCANNER : Analyse structurelle approfondie (Deep Scan)...
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

:: Lancement DISM
start /b cmd /c "dism /online /cleanup-image /scanhealth > "%TEMP_LOG%" 2>&1"

:loop_scanhealth
cls
echo.
echo  %F_GREEN%[1/3] INITIALISATION : Terminé.%CLR_RESET%
echo  %F_B_YELLOW%[2/3] SCANNER        : Analyse structurelle approfondie (Deep Scan)...%CLR_RESET%
echo.
echo  %F_B_YELLOW%[i]   NOTE           : Cette opération sollicite le processeur et le disque.%CLR_RESET%
if exist "%TEMP_LOG%" (
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 3 >nul
tasklist | find /i "dism.exe" >nul
if %errorlevel% equ 0 goto loop_scanhealth

:: Sauvegarde ScanHealth
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::GetEncoding(850)); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ '--- RESULTAT DISM SCANHEALTH ---' | Out-File '%LOG_FILE%' -Encoding utf8 -Append; $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"

:: ------------------------------------

:: --- ÉTAPE 3 : SFC VERIFYONLY ---
echo.
echo  [3/3] AUDIT : Vérification de la signature des fichiers système...
if exist "%TEMP_LOG%" del "%TEMP_LOG%" >nul 2>&1

:: Lancement SFC en mode vérification seule (ne répare rien)
start /b cmd /c "sfc /verifyonly > "%TEMP_LOG%" 2>&1"
:: ------------------------------------

:: ------------------------------------
:loop_sfc
cls
echo.
echo  %F_GREEN%[1/3] INITIALISATION   : Terminé.%CLR_RESET%
echo  %F_GREEN%[2/3] SCANNER          : Terminé.%CLR_RESET%
echo  %F_B_YELLOW%[3/3] AUDIT            : Vérification de la signature des fichiers système...%CLR_RESET%
echo.
echo  %F_B_YELLOW%[i]   NOTE             : Consolidation de la base WinSxS et purge des packages obsolètes.%CLR_RESET%
echo.
if exist "%TEMP_LOG%" (
    powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::Unicode); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){$t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-Host}"
)
timeout /t 2 >nul
tasklist | find /i "sfc.exe" >nul
if %errorlevel% equ 0 goto loop_sfc
:: ------------------------------------

:: Sauvegarde des logs
powershell -NoProfile -Command "$fs = New-Object System.IO.FileStream('%TEMP_LOG%', [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite); $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::Unicode); $t = $sr.ReadToEnd(); $sr.Close(); $fs.Close(); if($t){ '--- RESULTAT SFC VERIFYONLY ---' | Out-File '%LOG_FILE%' -Encoding utf8 -Append; $t -replace '[\x00-\x09\x0B\x0C\x0E-\x1F]','' | Out-File -FilePath '%LOG_FILE%' -Encoding utf8 -Append }"
:: ------------------------------------

del "%TEMP_LOG%" >nul 2>&1

echo.
echo ----------------------------------
echo Analyse terminee.
echo Log généré : "%LOG_FILE%"

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