# 1. Load dependencies
using module ".\src\Classes\CipherBase.psm1"
using module ".\src\Classes\OpenSSLCipher.psm1"
using module ".\src\Core\Benchmark.psm1"
using module ".\src\Utils\FileHelper.psm1"

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
    [OpenSSLCipher]::new("rc4-64", 64, $true),
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
            if ($report.Encrypt_ms -eq "N/A") {
                Write-Host " [N/A - Not Supported]" -ForegroundColor Gray
            }
            else {
                Write-Host " [OK]" -ForegroundColor Green
            }
        }
        catch {
            Write-Host " [ERROR]" -ForegroundColor Red
            Write-Host "DEBUG INFO: $($_.Exception.Message)" -ForegroundColor Gray
            Write-Host "COMMAND LOG: $cmd" -ForegroundColor DarkGray
        }
    }
    if (Test-Path $currentFile) { Remove-Item $currentFile }
}

$reportPath = Join-Path $PSScriptRoot "results"
if (!(Test-Path $reportPath)) { New-Item -ItemType Directory -Path $reportPath | Out-Null }

# Encryption Performance Report
Write-Host "`n" + ("=" * 75) -ForegroundColor White
Write-Host " PERFORMANCE REPORT: ENCRYPTION" -ForegroundColor Green
Write-Host ("=" * 75) -ForegroundColor White
$results | Select-Object Algorithm, 
    @{Name="Size"; Expression={$_.Original_KB.ToString() + " KB"}}, 
    @{Name="Encrypt_ms"; Expression={$_.Encrypt_ms}}, 
    Overhead_Bytes | Format-Table -AutoSize

# Decryption Performance Report
Write-Host "`n" + ("=" * 75) -ForegroundColor White
Write-Host " PERFORMANCE REPORT: DECRYPTION" -ForegroundColor Cyan
Write-Host ("=" * 75) -ForegroundColor White
$results | Select-Object Algorithm, 
    @{Name="Size"; Expression={$_.Original_KB.ToString() + " KB"}}, 
    @{Name="Decrypt_ms"; Expression={$_.Decrypt_ms}} | Format-Table -AutoSize

$csvFile = Join-Path $reportPath "Symmetric_Cipher_Performance_Results.csv"
$results | Export-Csv -Path $csvFile -NoTypeInformation -Encoding utf8
Write-Host "`n[COMPLETED] Results saved to: $csvFile" -ForegroundColor Yellow