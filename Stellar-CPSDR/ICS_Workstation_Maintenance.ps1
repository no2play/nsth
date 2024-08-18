# ICS_Workstation_Maintenance.ps1
# Description: A simple maintenance script for ICS workstations

Write-Host "========================================"
Write-Host "ICS Workstation Maintenance Script"
Write-Host "========================================"

# Step 1: Check Internet Connectivity
Write-Host "Checking internet connectivity..."
$pingResult = Test-Connection -ComputerName 8.8.8.8 -Count 4 -Quiet
if (-not $pingResult) {
    Write-Host "Internet connection failed. Please check the network settings."
    Write-Host "Exiting script."
    exit 1
} else {
    Write-Host "Internet connection is active."
}

# Step 2: Verify Connectivity to Management Server
Write-Host "Checking connectivity to management server (172.16.54.37)..."
$pingResult = Test-Connection -ComputerName 172.16.54.37 -Count 4 -Quiet
if (-not $pingResult) {
    Write-Host "Management server is unreachable. Please verify network connectivity."
    Write-Host "Exiting script."
    exit 1
} else {
    Write-Host "Management server is reachable."
}

# Step 3: Gather System Information
Write-Host "Gathering system information..."
Get-ComputerInfo | Select-Object CsName, OsName, OsArchitecture | Format-List
Write-Host ""

# Step 4: Find Current Logon Session and User
Write-Host "Finding current logon session and user..."
whoami
query session
Write-Host ""

# Step 5: Check the Status of Important Services
$servicesToCheck = @("wuauserv", "MSSQLSERVER") # Windows Update and SQL Server services

foreach ($service in $servicesToCheck) {
    $serviceStatus = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($null -eq $serviceStatus) {
        Write-Host "Service '$service' is not installed."
    } else {
        Write-Host "Service '$service' is $($serviceStatus.Status)."
    }
}
Write-Host ""

# Step 6: Disk Cleanup (Optional)
Write-Host "Performing disk cleanup..."
Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -NoNewWindow -Wait

Write-Host "========================================"
Write-Host "Maintenance tasks completed."
Write-Host "========================================"
pause
