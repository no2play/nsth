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

# Generate key and IV
$keyAndIv = Generate-AesKeyAndIv

# Output the results (optional)
Write-Output "Key (Bytes): $($keyAndIv.Key)"
Write-Output "IV (Bytes): $($keyAndIv.IV)"
