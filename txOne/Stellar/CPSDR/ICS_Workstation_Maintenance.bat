@echo off
REM Script: ICS_Workstation_Maintenance.bat
REM Description: A simple maintenance script for ICS workstations

echo ========================================
echo ICS Workstation Maintenance Script
echo ========================================

REM Step 1: Check Internet Connectivity
echo Checking internet connectivity...
ping 8.8.8.8 -n 4
if %errorlevel% neq 0 (
    echo Internet connection failed. Please check the network settings.
    echo Exiting script.
    exit /b 1
) else (
    echo Internet connection is active.
)

REM Step 2: Verify Connectivity to Management Server
echo Checking connectivity to management server (172.16.54.37)...
ping 172.16.54.37 -n 4
if %errorlevel% neq 0 (
    echo Management server is unreachable. Please verify network connectivity.
    echo Exiting script.
    exit /b 1
) else (
    echo Management server is reachable.
)

REM Step 3: Gather System Information
echo Gathering system information...
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
echo.

REM Step 4: Find Current Logon Session and User
echo Finding current logon session and user...
whoami /user
query session
echo.

REM Step 5: Check the Status of Important Services
set ServicesToCheck=WindowsUpdate StellarProtectService

for %%s in (%ServicesToCheck%) do (
    sc query "%%s" >nul 2>&1
    if %errorlevel% neq 0 (
        echo Service "%%s" is not installed.
    ) else (
        sc query "%%s" | findstr /C:"STATE"
    )
)
echo.

REM Step 6: Disk Cleanup (Optional)
echo Performing disk cleanup...
cleanmgr /sagerun:1

echo ========================================
echo Maintenance tasks completed.
echo ========================================
pause
exit /b 0
