@echo off
title Outil de reparation Windows

:: Activation de l'affichage propre
color 0A

echo ==================================================
echo        OUTIL DE REPARATION WINDOWS
echo ==================================================
echo.
echo Merci de ne PAS fermer cette fenetre pendant l'execution.
echo Cela peut prendre plusieurs minutes.
echo.

pause

cls

echo [ETAPE 1/2] Verification et reparation de l'image Windows (DISM)
echo --------------------------------------------------
echo Cette operation peut etre longue...
echo.

DISM /Online /Cleanup-Image /RestoreHealth

if %errorlevel% neq 0 (
    echo.
    echo [ERREUR] DISM a rencontre un probleme.
    echo Code erreur: %errorlevel%
    echo.
    echo Vous pouvez continuer, mais certaines reparations peuvent echouer.
    pause
) else (
    echo.
    echo [OK] DISM termine avec succes.
    pause
)

cls

echo [ETAPE 2/2] Verification des fichiers systeme (SFC)
echo --------------------------------------------------
echo Analyse en cours...
echo.

sfc /scannow

if %errorlevel% neq 0 (
    echo.
    echo [ATTENTION] SFC a detecte des problemes.
    echo Code retour: %errorlevel%
) else (
    echo.
    echo [OK] Aucune erreur critique detectee.
)

echo.
echo ==================================================
echo                OPERATION TERMINEE
echo ==================================================
echo.
echo Vous pouvez maintenant fermer cette fenetre.
echo Il est recommande de redemarrer votre ordinateur.
echo.

pause