param($tempDir, $logFile)

# On récupère les services qui ne sont pas dans C:\Windows
$services = Get-CimInstance Win32_Service | Where-Object { $_.PathName -and ($_.PathName -notlike 'C:\Windows*') }

$bad = foreach ($s in $services) { 
    $path = $s.PathName.Trim()
    $finalPath = ""

    # Cas 1 : Le chemin est entre guillemets (ex: "C:\Program Files\...")
    if ($path.StartsWith('"')) {
        $finalPath = $path.Split('"')[1]
    } 
    # Cas 2 : Pas de guillemets, mais peut avoir des arguments (ex: C:\MonDossier\app.exe /svc)
    else {
        if (-not (Test-Path $path)) {
            $finalPath = $path.Split(' ')[0]
        } else {
            $finalPath = $path
        }
    }

    # Vérification finale de l'existence du fichier
    if ($finalPath -and -not (Test-Path $finalPath)) { 
        "$($s.Name) -> $($s.PathName)" 
    } 
}

# --- GESTION DE L'AFFICHAGE ET DU LOG ---
if ($bad) { 
    Write-Host "  [!] Services orphelins (fichiers introuvables) :" -ForegroundColor Yellow
    $bad | Write-Host -ForegroundColor White
    
    # Écriture dans le log
    $header = "`r`n --- SERVICES ORPHELINS DETECTES ---"
    $header | Out-File $logFile -Append -Encoding utf8
    $bad | Out-File $logFile -Append -Encoding utf8
} else { 
    # Affichage Console (SANS ACCENTS)
    Write-Host "  [+] Aucun service orphelin detecte." -ForegroundColor Green
    
    # Écriture dans le log (SANS ACCENTS)
    $msg = "`r`n --- SERVICES ORPHELINS : Aucun detecte (Systeme propre) ---"
    $msg | Out-File $logFile -Append -Encoding utf8
}