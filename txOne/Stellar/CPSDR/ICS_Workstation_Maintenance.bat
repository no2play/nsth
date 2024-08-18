@echo off
REM Script: ICS_Workstation_Maintenance.bat
REM Description: A simple maintenance script for ICS workstations

echo ========================================
echo ICS Workstation Maintenance Script
echo ========================================

REM Step 1: Check Network Connectivity
echo Checking network connectivity...
ping 8.8.8.8 -n 4
if %errorlevel% neq 0 (
    echo Network connection failed. Please check the network settings.
    echo Exiting script.
    exit /b 1
) else (
    echo Network connection is active.
)

REM Step 2: Gather System Information
echo Gathering system information...
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
echo.

REM Step 3: Check Service Status
echo Checking the status of important services...
sc query "Windows Update"
sc query "MSSQLSERVER"  REM Example service (replace with actual service name)

REM Step 4: Disk Cleanup (Optional)
echo Performing disk cleanup...
cleanmgr /sagerun:1

echo ========================================
echo Maintenance tasks completed.
echo ========================================
pause
exit /b 0
