# Advanced System Diagnostic & Health Check Tool
# Erstellt von: João Zamba
# Beschreibung: Dieses Skript führt eine vollständige Systemanalyse durch und speichert die Ergebnisse in einer Log-Datei.

$logFile = "C:\Advanced_System_Report.txt"

Write-Host "Starte Systemdiagnose..." -ForegroundColor Cyan

# 1. Systeminformationen erfassen
Write-Host "Sammle Systeminformationen..." -ForegroundColor Yellow
$sysInfo = Get-ComputerInfo | Select-Object CsName, OsName, WindowsVersion, WindowsBuildLabEx, CsManufacturer, CsModel, CsTotalPhysicalMemory
$sysInfo | Format-Table -AutoSize | Out-File -FilePath $logFile

# 2. CPU- & RAM-Nutzung
Write-Host "Überprüfe CPU- und RAM-Nutzung..." -ForegroundColor Yellow
$cpuLoad = Get-Counter '\Processor(_Total)\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
$cpuUsage = [math]::Round($cpuLoad, 2)
$ram = Get-CimInstance Win32_OperatingSystem
$ramTotal = [math]::Round($ram.TotalVisibleMemorySize / 1MB, 2)
$ramFree = [math]::Round($ram.FreePhysicalMemory / 1MB, 2)
$ramUsed = $ramTotal - $ramFree

"CPU-Auslastung: $cpuUsage%
Gesamter RAM: $ramTotal GB, Genutzt: $ramUsed GB, Frei: $ramFree GB" | Out-File -Append -FilePath $logFile

# 3. Netzwerkstatus prüfen
Write-Host "Überprüfe Netzwerkverbindung..." -ForegroundColor Yellow
$gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0").NextHop
$pingGoogle = Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet
$dnsTest = Resolve-DnsName google.com -ErrorAction SilentlyContinue

"Standard-Gateway: $gateway
Internetverbindung: $(if ($pingGoogle) {"OK"} else {"Fehlgeschlagen"})
DNS-Auflösung: $(if ($dnsTest) {"Erfolgreich"} else {"Fehlgeschlagen"})" | Out-File -Append -FilePath $logFile

# 4. Windows-Ereignisprotokolle auf Fehler prüfen
Write-Host "Scanne Windows-Ereignisprotokolle nach kritischen Fehlern..." -ForegroundColor Yellow
$errors = Get-WinEvent -LogName System -MaxEvents 20 | Where-Object { $_.LevelDisplayName -eq "Error" }
$errors | Format-Table TimeCreated, Id, ProviderName, Message -AutoSize | Out-File -Append -FilePath $logFile

# 5. Laufende Dienste und Treiber
Write-Host "Erfasse laufende Dienste und Treiber..." -ForegroundColor Yellow
$services = Get-Service | Where-Object { $_.Status -eq "Running" }
$drivers = Get-WmiObject Win32_PnPSignedDriver | Select-Object DeviceName, DriverVersion, Manufacturer

$services | Format-Table Name, DisplayName, Status -AutoSize | Out-File -Append -FilePath $logFile
$drivers | Format-Table DeviceName, DriverVersion, Manufacturer -AutoSize | Out-File -Append -FilePath $logFile

Write-Host "Systemdiagnose abgeschlossen! Ergebnisse gespeichert in: $logFile" -ForegroundColor Green
