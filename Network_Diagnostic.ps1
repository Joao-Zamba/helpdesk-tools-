# Netzwerk Troubleshooting Tool
# Erstellt von: João Zamba
# Beschreibung: Dieses Skript überprüft die Netzwerkkonfiguration und testet die Internetverbindung.

# 1. Netzwerkadapter & IP-Adresse auslesen
Write-Host "Netzwerkkonfiguration prüfen..." -ForegroundColor Cyan
$networkInfo = Get-NetIPConfiguration | Select-Object InterfaceAlias, InterfaceDescription, IPv4Address, IPv6Address, DNSServer
$networkInfo | Format-Table -AutoSize

# 2. Standard-Gateway & Internetverbindung testen
Write-Host "Ping-Test zur Standard-Gateway..." -ForegroundColor Cyan
$gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0").NextHop
if ($gateway) {
    $pingGateway = Test-Connection -ComputerName $gateway -Count 2 -ErrorAction SilentlyContinue
    if ($pingGateway) {
        Write-Host "Standard-Gateway erreichbar: $gateway" -ForegroundColor Green
    } else {
        Write-Host "KEIN Zugriff auf Standard-Gateway!" -ForegroundColor Red
    }
} else {
    Write-Host "Kein Standard-Gateway gefunden!" -ForegroundColor Red
}

# 3. Internetzugriff mit Ping-Test zu Google prüfen
Write-Host "Internetverbindung testen..." -ForegroundColor Cyan
$pingGoogle = Test-Connection -ComputerName 8.8.8.8 -Count 2 -ErrorAction SilentlyContinue
if ($pingGoogle) {
    Write-Host "Internetverbindung OK (Google antwortet)." -ForegroundColor Green
} else {
    Write-Host "KEIN Internetzugriff!" -ForegroundColor Red
}

# 4. DNS-Server überprüfen
Write-Host "DNS-Server Test..." -ForegroundColor Cyan
$dnsTest = Resolve-DnsName google.com -ErrorAction SilentlyContinue
if ($dnsTest) {
    Write-Host "DNS-Auflösung funktioniert." -ForegroundColor Green
} else {
    Write-Host "DNS-Problem! Keine Namensauflösung möglich." -ForegroundColor Red
}

# 5. Ergebnisse in eine Log-Datei schreiben
$logFile = "C:\Network_Diagnostic_Report.txt"
Write-Host "Ergebnisse werden in $logFile gespeichert..." -ForegroundColor Yellow
"Netzwerkkonfiguration:`n$networkInfo`n`nStandard-Gateway: $gateway`nInternetverbindung: $(if ($pingGoogle) {"OK"} else {"KEIN Internet"})`nDNS-Test: $(if ($dnsTest) {"Erfolgreich"} else {"Fehlgeschlagen"})" | Out-File -FilePath $logFile
Write-Host "Netzwerkdiagnose abgeschlossen! Log-Datei gespeichert." -ForegroundColor Green
