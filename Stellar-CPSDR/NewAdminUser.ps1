# List all local administrators
Write-Host "Listing all local administrators:"
Get-LocalGroupMember -Group "Administrators" | Select-Object -Property Name

# Define the new user details
$newUsername = "NewAdminUser"  # Replace with the desired username
$newPassword = "P@ssw0rd!"      # Replace with the desired password

# Create the new user
Write-Host "Creating new user $newUsername..."
New-LocalUser -Name $newUsername -Password (ConvertTo-SecureString $newPassword -AsPlainText -Force) -FullName "New Admin User" -Description "Admin User" -PasswordNeverExpires $true

# Add the new user to the Administrators group
Write-Host "Adding $newUsername to the Administrators group..."
Add-LocalGroupMember -Group "Administrators" -Member $newUsername

# Add the new user to the Remote Desktop Users group
Write-Host "Adding $newUsername to the Remote Desktop Users group..."
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $newUsername

Write-Host "New user $newUsername created with admin and RDP permissions."
