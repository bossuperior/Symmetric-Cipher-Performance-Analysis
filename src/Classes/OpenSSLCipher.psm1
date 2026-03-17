using module ".\CipherBase.psm1"
class OpenSSLCipher : CipherBase {
    
    OpenSSLCipher([string]$name, [int]$keySize, [bool]$isLegacy) 
    : base($name, $keySize, $isLegacy) { }

    [void] Encrypt([string]$inputFile, [string]$outputFile, [securestring]$securePassword) {
        $providerArgs = $this.GetProviderArgs()
        
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
        try {
            $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
            $algo = $this.AlgorithmName.ToLower()
            $cmd = "openssl enc -$algo -e -in `"$inputFile`" -out `"$outputFile`" -k `"$plainPassword`" -nosalt $providerArgs"
            Invoke-Expression $cmd
        }
        finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }

    [void] Decrypt([string]$inputFile, [string]$outputFile, [securestring]$securePassword) {
        $providerArgs = $this.GetProviderArgs()
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
        try {
            $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
            $cmd = "openssl enc -$($this.AlgorithmName) -d -in `"$inputFile`" -out `"$outputFile`" -k `"$plainPassword`" -nosalt $providerArgs"
            Invoke-Expression $cmd
        }
        finally {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}