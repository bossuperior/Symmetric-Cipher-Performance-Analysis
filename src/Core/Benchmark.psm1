using module "..\Classes\CipherBase.psm1"

class Benchmark {
    [CipherBase]$Cipher
    
    Benchmark([CipherBase]$cipher) {
        $this.Cipher = $cipher
    }

    [PSCustomObject] Run([string]$inputFile, [securestring]$securePassword) {
        $outputFile = Join-Path $PSScriptRoot "..\..\data\output\temp_encrypted.txt"
        $decryptedFile = Join-Path $PSScriptRoot "..\..\data\output\temp_decrypted.txt"

        $outDir = Split-Path $outputFile
        if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

        $originalSize = (Get-Item $inputFile).Length
        $encryptedSize = 0
        $encTime = $null
        $decTime = $null

        try {
            $encTime = Measure-Command {
                $this.Cipher.Encrypt($inputFile, $outputFile, $securePassword)
            }
            if (!(Test-Path $outputFile) -or (Get-Item $outputFile).Length -eq 0) {
                throw "Encryption failed: Output file not found or empty."
            }
            $encryptedSize = (Get-Item $outputFile).Length

            $decTime = Measure-Command {
                $this.Cipher.Decrypt($outputFile, $decryptedFile, $securePassword)
            }

            # Calculate overhead in bytes
            $overhead = $encryptedSize - $originalSize

            #Throughput in MB/s
            $throughputValue = if ($encTime.TotalSeconds -gt 0) {
                [math]::Round(($originalSize / 1MB) / $encTime.TotalSeconds, 2)
            }
            else { 0 }

            return [PSCustomObject]@{
                Algorithm      = $this.Cipher.AlgorithmName
                Original_KB    = [math]::Round($originalSize / 1KB, 2)
                Encrypted_KB   = [math]::Round($encryptedSize / 1KB, 2)
                Overhead_Bytes = $overhead
                Encrypt_ms     = [math]::Round($encTime.TotalMilliseconds, 2)
                Decrypt_ms     = [math]::Round($decTime.TotalMilliseconds, 2)
                Throughput_MBs = $throughputValue
            }
        }
        catch {
            return [PSCustomObject]@{
                Algorithm      = $this.Cipher.AlgorithmName
                Original_KB    = [math]::Round($originalSize / 1KB, 2)
                Encrypted_KB   = "N/A"
                Overhead_Bytes = "N/A"
                Encrypt_ms     = "N/A"
                Decrypt_ms     = "N/A"
                Throughput_MBs = "N/A"
            }
        }
        finally {
            if (Test-Path $outputFile) { Remove-Item $outputFile -Force }
            if (Test-Path $decryptedFile) { Remove-Item $decryptedFile -Force }
        }
    }
}