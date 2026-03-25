@echo off
:: Génération du caractère d'échappement ESC (Universel Windows 10/11)
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

:: --- RESET ---
set "CLR_RESET=%ESC%[0m"

:: --- STYLES ---
set "FX_BOLD=%ESC%[1m"       & :: Gras
set "FX_DIM=%ESC%[2m"        & :: Sombre / Faible intensité
set "FX_ITALIC=%ESC%[3m"     & :: Italique
set "FX_UNDER=%ESC%[4m"      & :: Souligné
set "FX_BLINK=%ESC%[5m"      & :: Clignotant
set "FX_STRIKE=%ESC%[9m"     & :: Barré
set "FX_INVERT=%ESC%[7m"     & :: Inverse (Fond <-> Texte)
set "FX_HIDE=%ESC%[8m"       & :: Masqué (Utile pour les mots de passe)

:: --- COULEURS TEXTE (FOREGROUND - 16 Couleurs Standard) ---
set "F_BLACK=%ESC%[30m"
set "F_RED=%ESC%[31m"
set "F_GREEN=%ESC%[32m"
set "F_YELLOW=%ESC%[33m"
set "F_BLUE=%ESC%[34m"
set "F_MAGENTA=%ESC%[35m"
set "F_CYAN=%ESC%[36m"
set "F_WHITE=%ESC%[37m"

:: --- COULEURS TEXTE INTENSES (Bright) ---
set "F_GRAY=%ESC%[90m"
set "F_B_RED=%ESC%[91m"
set "F_B_GREEN=%ESC%[92m"
set "F_B_YELLOW=%ESC%[93m"
set "F_B_BLUE=%ESC%[94m"
set "F_B_MAGENTA=%ESC%[95m"
set "F_B_CYAN=%ESC%[96m"
set "F_B_WHITE=%ESC%[97m"

:: --- COULEURS FOND (BACKGROUND) ---
set "B_BLACK=%ESC%[40m"
set "B_RED=%ESC%[41m"
set "B_GREEN=%ESC%[42m"
set "B_YELLOW=%ESC%[43m"
set "B_BLUE=%ESC%[44m"
set "B_MAGENTA=%ESC%[45m"
set "B_CYAN=%ESC%[46m"
set "B_WHITE=%ESC%[47m"
set "B_B_GRAY=%ESC%[100m"

:: --- COULEURS ÉTENDUES (Palette 256 - Sélection des plus utiles) ---
set "F_ORANGE=%ESC%[38;5;208m"
set "F_PURPLE=%ESC%[38;5;141m"
set "F_PINK=%ESC%[38;5;201m"
set "F_TEAL=%ESC%[38;5;30m"
set "F_GOLD=%ESC%[38;5;214m"
set "F_MATRIX=%ESC%[38;5;46m"
set "F_SKY=%ESC%[38;5;117m"

:: --- COMBINAISONS UTILES (Pour tes menus) ---
set "MENU_SELECT=%ESC%[48;5;238m%ESC%[38;5;82m%FX_BOLD%" & :: Fond gris foncé, texte vert fluo, gras
set "ALERT_ERR=%ESC%[41m%ESC%[97m%FX_BOLD%"              & :: Fond rouge, texte blanc, gras
set "SUCCESS=%ESC%[32m%FX_BOLD%"                         & :: Texte vert, gras

:: Masquer l'affichage des commandes si appelé directement
if "%~1"=="--info" (
    echo %F_B_CYAN%Thème complet chargé.%CLR_RESET%
    echo %F_ORANGE%Exemple d'alerte : %ALERT_ERR% ERREUR SYSTEME %CLR_RESET%
    echo %F_PURPLE%Exemple de menu : %MENU_SELECT% ^> OPTION CHOISIE %CLR_RESET%
)