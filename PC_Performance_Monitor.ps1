# PC Performance Monitoring Tool
# Erstellt von: João Zamba
# Beschreibung: Dieses Skript überwacht CPU, RAM und Festplattennutzung in Echtzeit.

# 1. CPU-Auslastung anzeigen
Write-Host "CPU-Auslastung prüfen..." -ForegroundColor Cyan
$cpuLoad = Get-Counter '\Processor(_Total)\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
$cpuUsage = [math]::Round($cpuLoad, 2)
Write-Host "Aktuelle CPU-Auslastung: $cpuUsage%" -ForegroundColor Yellow

# 2. RAM-Nutzung prüfen
Write-Host "RAM-Nutzung prüfen..." -ForegroundColor Cyan
$ram = Get-CimInstance Win32_OperatingSystem
$ramTotal = [math]::Round($ram.TotalVisibleMemorySize / 1MB, 2)
$ramFree = [math]::Round($ram.FreePhysicalMemory / 1MB, 2)
$ramUsed = $ramTotal - $ramFree
Write-Host "Gesamter RAM: $ramTotal GB" -ForegroundColor Yellow
Write-Host "Genutzter RAM: $ramUsed GB" -ForegroundColor Yellow
Write-Host "Freier RAM: $ramFree GB" -ForegroundColor Yellow

# 3. Festplattenspeicher prüfen
Write-Host "Festplattenspeicher prüfen..." -ForegroundColor Cyan
$disk = Get-PSDrive C | Select-Object Used, Free
Write-Host "Genutzter Speicher: $([math]::Round($disk.Used / 1GB, 2)) GB" -ForegroundColor Yellow
Write-Host "Freier Speicher: $([math]::Round($disk.Free / 1GB, 2)) GB" -ForegroundColor Yellow

# 4. Top 5 Prozesse nach CPU-Verbrauch
Write-Host "Top 5 Prozesse nach CPU-Auslastung..." -ForegroundColor Cyan
$topProcesses = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 ProcessName, CPU
$topProcesses | Format-Table -AutoSize

# 5. Ergebnisse in eine Log-Datei schreiben
$logFile = "C:\PC_Performance_Report.txt"
Write-Host "Ergebnisse werden in $logFile gespeichert..." -ForegroundColor Yellow
"CPU-Auslastung: $cpuUsage%
RAM: Gesamt $ramTotal GB, Genutzt $ramUsed GB, Frei $ramFree GB
Festplatte: Genutzt $([math]::Round($disk.Used / 1GB, 2)) GB, Frei $([math]::Round($disk.Free / 1GB, 2)) GB
Top 5 CPU-Prozesse:
$($topProcesses | Out-String)" | Out-File -FilePath $logFile
Write-Host "Performance-Überwachung abgeschlossen! Log-Datei gespeichert." -ForegroundColor Green
