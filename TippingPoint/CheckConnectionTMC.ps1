# Define URLs, ports, and functions
$connections = @(
    @{Hostname = "tmc.tippingpoint.com"; IP = "varies"; Port = 80; Function = "Redirects to https://tmc.tippingpoint.com"},
    @{Hostname = "tmc.tippingpoint.com"; IP = "varies"; Port = 443; Function = "Web User Interface to TMC"},
    @{Hostname = "tmc.tippingpoint.com"; IP = "varies"; Port = 4043; Function = "Legacy IPS/SMS auto-download service"},
    @{Hostname = "ws.tippingpoint.com"; IP = "varies"; Port = 443; Function = "TPS/IPS/SMS auto-download service"},
    @{Hostname = "d.tippingpoint.com"; IP = "varies"; Port = 80; Function = "Redirects to Akamai for downloads"},
    @{Hostname = "i.tippingpoint.com"; IP = "varies"; Port = 80; Function = "TPS/IPS package auto-download service"},
    @{Hostname = "threatlinq.tippingpoint.com"; IP = "varies"; Port = 80; Function = "Web User Interface to ThreatLinQ"},
    @{Hostname = "threatlinq.tippingpoint.com"; IP = "varies"; Port = 443; Function = "Web User Interface to ThreatLinQ"}
)

# Function to check connectivity
function Test-ConnectionDetails {
    param (
        [string]$Hostname,
        [int]$Port,
        [string]$Function
    )

    Write-Host "Testing $Hostname on port $Port ($Function)..." -ForegroundColor Yellow
    $result = Test-NetConnection -ComputerName $Hostname -Port $Port -WarningAction SilentlyContinue

    if ($result.TcpTestSucceeded) {
        Write-Host "Success: Connected to $Hostname on port $Port" -ForegroundColor Green
        [PSCustomObject]@{
            Hostname = $Hostname
            Port = $Port
            Function = $Function
            Status = "Connected"
        }
    } else {
        Write-Host "Failed: Cannot connect to $Hostname on port $Port" -ForegroundColor Red
        [PSCustomObject]@{
            Hostname = $Hostname
            Port = $Port
            Function = $Function
            Status = "Failed"
        }
    }
}

# Run connectivity tests and output results
$results = foreach ($connection in $connections) {
    Test-ConnectionDetails -Hostname $connection.Hostname -Port $connection.Port -Function $connection.Function
}

# Export results to a CSV file
$results | Export-Csv -Path "ConnectivityResults.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Connectivity tests completed. Results exported to ConnectivityResults.csv." -ForegroundColor Cyan
