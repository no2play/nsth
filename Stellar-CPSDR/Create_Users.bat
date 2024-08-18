@echo off
:: Batch script to create a local user using PowerShell

:: Define the username and password
set "username=Attacker"
set "password=P@ssw0rd123"

:: Run the PowerShell command to create the user
powershell -Command "New-LocalUser -Name '%username%' -Password (ConvertTo-SecureString '%password%' -AsPlainText -Force) -FullName 'New User' -Description 'New local user account' -PasswordNeverExpires:$true"

:: Add the user to the Administrators group (optional)
powershell -Command "Add-LocalGroupMember -Group 'Administrators' -Member '%username%'"

echo User %username% created successfully.
pause
