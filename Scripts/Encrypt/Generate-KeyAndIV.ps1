# Function to generate a random key and IV for AES encryption
function Generate-AesKeyAndIv {
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.GenerateKey()
    $aes.GenerateIV()

    # Convert byte arrays to Base64 strings for easy handling
    $keyBase64 = [System.Convert]::ToBase64String($aes.Key)
    $ivBase64 = [System.Convert]::ToBase64String($aes.IV)

    [PSCustomObject]@{
        Key = $keyBase64
        IV = $ivBase64
    }
}

# Generate key and IV
$keyAndIv = Generate-AesKeyAndIv

# Output the results
Write-Output "Key (Base64): $($keyAndIv.Key)"
Write-Output "IV (Base64): $($keyAndIv.IV)"
