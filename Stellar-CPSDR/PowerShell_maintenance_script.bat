@echo off
REM Batch file to run the PowerShell maintenance script

REM Step 1: Check if PowerShell script exists
if not exist "ICS_Workstation_Maintenance.ps1" (
    echo PowerShell script not found!
    pause
    exit /b 1
)

REM Step 2: Run the PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -File "ICS_Workstation_Maintenance.ps1"
