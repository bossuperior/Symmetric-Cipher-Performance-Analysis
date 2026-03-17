class CipherBase {
    [string]$AlgorithmName
    [int]$KeySize
    [bool]$IsLegacy
    [string]$ProviderPath

    CipherBase([string]$name, [int]$keySize, [bool]$isLegacy) {
        $this.AlgorithmName = $name
        $this.KeySize = $keySize
        $this.IsLegacy = $isLegacy
        $this.ProviderPath = "C:\Program Files\OpenSSL-Win64\bin"
    }

    [void] Encrypt([string]$inputFile, [string]$outputFile, [securestring]$securePassword) {
        throw "Method 'Encrypt' must be implemented."
    }

    [void] Decrypt([string]$inputFile, [string]$outputFile, [securestring]$securePassword) {
        throw "Method 'Decrypt' must be implemented."
    }

    [string] GetProviderArgs() {
        return if ($this.IsLegacy) { "-provider legacy -provider default" } else { "" }
    }
}