@echo off
cd /d "%~dp0"

title Repair Tool by h0ldhaven
color 0A

:MENU
cls
echo.
echo ===============================================
echo        REPAIR TOOL - WINDOWS REPAIR
echo ===============================================
echo.
echo 1 - Analyse systeme
echo 2 - Reparation systeme
echo 3 - Analyse + Reparation
echo 0 - Quitter
echo.

choice /c 1230 /n /m "Choisissez une option : "

if errorlevel 4 exit
if errorlevel 3 call all.bat
if errorlevel 2 call repair.bat
if errorlevel 1 call analyze.bat

goto MENU