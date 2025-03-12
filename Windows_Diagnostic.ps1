# Windows System Diagnostic Script
# Erstellt von: João Zamba
# Beschreibung: Dieses Skript sammelt Systeminformationen, prüft die Internetverbindung
# und analysiert Windows-Ereignisprotokolle auf Fehler.

# 1. Systeminformationen anzeigen
Write-Host "Systeminformationen sammeln..." -ForegroundColor Cyan
$systemInfo = Get-ComputerInfo | Select-Object CsName, OsName, OsArchitecture, WindowsVersion, WindowsBuildLabEx
$systemInfo | Format-Table -AutoSize

# 2. RAM und Festplattenspeicher prüfen
Write-Host "Speicherinformationen..." -ForegroundColor Cyan
$ram = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
$ramGB = [math]::Round($ram.Sum / 1GB, 2)
$disk = Get-PSDrive C | Select-Object Used, Free
Write-Host "RAM: $ramGB GB"
Write-Host "Freier Speicher auf C: $($disk.Free / 1GB) GB"

# 3. Internetverbindung prüfen
Write-Host "Internetverbindung testen..." -ForegroundColor Cyan
$ping = Test-Connection -ComputerName google.com -Count 2 -ErrorAction SilentlyContinue
if ($ping) {
    Write-Host "Internetverbindung OK" -ForegroundColor Green
} else {
    Write-Host "KEINE Internetverbindung!" -ForegroundColor Red
}

# 4. Windows-Ereignisprotokolle nach Fehlern durchsuchen
Write-Host "Letzte 10 Fehler im Windows-Ereignisprotokoll..." -ForegroundColor Cyan
$errors = Get-EventLog -LogName System -EntryType Error -Newest 10
if ($errors) {
    $errors | Format-Table TimeGenerated, Source, EventID, Message -AutoSize
} else {
    Write-Host "Keine Fehler gefunden." -ForegroundColor Green
}

# 5. Ergebnisse in eine Log-Datei schreiben
$logFile = "C:\Windows_Diagnostic_Report.txt"
Write-Host "Ergebnisse werden in $logFile gespeichert..." -ForegroundColor Yellow
"Systeminfo:`n$systemInfo`n`nSpeicher:`nRAM: $ramGB GB, Freier Speicher auf C: $($disk.Free / 1GB) GB`n`nInternetverbindung: $(if ($ping) {"OK"} else {"KEIN Internet"})`n`nLetzte Fehler:`n$errors" | Out-File -FilePath $logFile
Write-Host "Diagnose abgeschlossen! Log-Datei gespeichert." -ForegroundColor Green

Initial commit for diagnostic script
