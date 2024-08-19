# Check WinRM service status
Write-Host "Checking WinRM service status..."
$winRMStatus = Get-Service -Name WinRM
if ($winRMStatus.Status -eq "Running") {
    Write-Host "WinRM service is running."
} else {
    Write-Host "WinRM service is not running."
}

# Check WMI service status
Write-Host "`nChecking WMI service status..."
$wmiStatus = Get-Service -Name winmgmt
if ($wmiStatus.Status -eq "Running") {
    Write-Host "WMI (winmgmt) service is running."
} else {
    Write-Host "WMI (winmgmt) service is not running."
}

# Check if port 5985 (WinRM) is open
Write-Host "`nChecking if port 5985 (WinRM) is open..."
if ((Test-NetConnection -Port 5985 -ComputerName localhost).TcpTestSucceeded) {
    Write-Host "Port 5985 is open and listening."
} else {
    Write-Host "Port 5985 is not open."
}

# Check if port 135 (WMI) is open
Write-Host "`nChecking if port 135 (WMI) is open..."
if ((Test-NetConnection -Port 135 -ComputerName localhost).TcpTestSucceeded) {
    Write-Host "Port 135 is open and listening."
} else {
    Write-Host "Port 135 is not open."
}

Write-Host "`nScript execution completed."
