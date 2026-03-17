# 1. Load dependencies
Import-Module "$PSScriptRoot\src\Classes\CipherBase.psm1"
Import-Module "$PSScriptRoot\src\Classes\OpenSSLCipher.psm1"
Import-Module "$PSScriptRoot\src\Core\Benchmark.psm1"
Import-Module "$PSScriptRoot\src\Utils\FileHelper.psm1"

# Setup Environment & Input
Write-Host "`n--- Symmetric Encryption Tool ---" -ForegroundColor Magenta
$userText = Read-Host "Enter the text you want to encrypt"
$testFile = Join-Path $PSScriptRoot "input_message.txt"
$userText | Out-File $testFile -Encoding utf8
$password = Read-Host "Enter encryption password" -AsSecureString
$fileSizes = @("100B", "10kB", "1MB", "100MB")
$results = @()

# Define the list of Ciphers to test
$cipherList = @(
    [OpenSSLCipher]::new("des-ecb", 56, $true),
    [OpenSSLCipher]::new("des-cbc", 56, $true),
    [OpenSSLCipher]::new("des-ede3-ecb", 168, $true),
    [OpenSSLCipher]::new("des-ede3-cbc", 168, $true),
    [OpenSSLCipher]::new("aes-128-ecb", 128, $false),
    [OpenSSLCipher]::new("aes-128-cbc", 128, $false),
    [OpenSSLCipher]::new("aes-256-ecb", 256, $false),
    [OpenSSLCipher]::new("aes-256-cbc", 256, $false),
    [OpenSSLCipher]::new("rc4", 128, $true),
    [OpenSSLCipher]::new("rc4", 64, $true),
    [OpenSSLCipher]::new("rc4-40", 40, $true)
)

Write-Host "`n>>> Starting Symmetric Encryption Benchmark <<<" -ForegroundColor Cyan

# Run Benchmarks
foreach ($sizeName in $fileSizes) {
    $bytes = [FileHelper]::ConvertToBytes($sizeName)
    $currentFile = [FileHelper]::CreateRandomFile("test_$sizeName.txt", $bytes)
    
    Write-Host "`nTesting File Size: $sizeName" -ForegroundColor Yellow

    foreach ($cipherObj in $cipherList) {
        try {
            Write-Host " -> $($cipherObj.AlgorithmName)..." -NoNewline
            $bench = [Benchmark]::new($cipherObj)
            $report = $bench.Run($currentFile, $password)
            
            $results += $report
            Write-Host " [OK]" -ForegroundColor Green
        }
        catch {
            Write-Host " [ERROR]" -ForegroundColor Red
        }
    }
    if (Test-Path $currentFile) { Remove-Item $currentFile }
}

$results | Select-Object Algorithm, Size, Encrypt_ms, Overhead_Bytes | Format-Table -AutoSize