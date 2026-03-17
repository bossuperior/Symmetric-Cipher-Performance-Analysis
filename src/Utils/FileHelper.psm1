class FileHelper {
    # Generate a random binary file using OpenSSL rand
    static[string] CreateRandomFile([string]$fileName, [long]$sizeInBytes) {
        if ($fileName -notlike "*.txt") { $fileName += ".txt" }
        $path = Join-Path $PSScriptRoot "..\..\data\input\$fileName"
        
        # Ensure directory exists
        $dir = Split-Path $path
        if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

        # Execute OpenSSL to create random data
        openssl rand -out $path $sizeInBytes
        return $path
    }

    # Helper to convert friendly sizes (like "1MB") to bytes
    static [long] ConvertToBytes([string]$sizeStr) {
        $upperSize = $sizeStr.ToUpper()
    
        if ($upperSize -like "*MB") { 
            return [long]($upperSize.Replace("MB", "")) * 1MB 
        }
        if ($upperSize -like "*KB") { 
            return [long]($upperSize.Replace("KB", "")) * 1KB 
        }
        if ($upperSize -like "*B") { 
            return [long]($upperSize.Replace("B", "")) 
        }
        return [long]$upperSize
    }
}