# Symmetric Cipher Performance Analysis

A professional benchmarking tool designed to evaluate and compare the performance of various symmetric encryption algorithms. This project leverages **OpenSSL** and is built using **Object-Oriented Programming (OOP)** principles in PowerShell.

## 🏗️ Software Architecture
The project follows a modular design to ensure scalability and clean code:
- **Abstraction:** `CipherBase` defines the template for all encryption tools.
- **Inheritance:** `OpenSSLCipher` implements specific OpenSSL logic.
- **Polymorphism:** The `Benchmark` core can process any object derived from `CipherBase`.
- **Encapsulation:** Hardware-specific logic and file I/O are hidden within specialized classes.

## 🔐 Security Features
- **Memory Protection:** Utilizes `[SecureString]` to handle passwords, ensuring sensitive data is encrypted in RAM.
- **Safe Cleanup:** Implements `ZeroFreeBSTR` to wipe plain-text passwords from memory immediately after use.
- **Provider Management:** Automatically handles OpenSSL 3.x `legacy` and `default` providers for older algorithms (DES, 3DES, RC4).

## 📂 Project Structure
```text
Symmetric-Cipher-Performance-Analysis/
├── src/
│   ├── Classes/
│   │   ├── CipherBase.psm1      # Abstract-like base class
│   │   └── OpenSSLCipher.psm1   # Implementation for OpenSSL
│   ├── Core/
│   │   └── Benchmark.psm1      # Performance measurement logic
│   └── Utils/
│       └── FileHelper.psm1     # Data generation and unit conversion
├── data/                       # Local test data (Ignored by Git)
└── Main.ps1                    # Application entry point

## 🛠️ Setup & Installation

### 1. Install OpenSSL
To run this project, you must have OpenSSL installed on your system.

* **Option A: Manual Install (Windows)**
    1. Download the installer from [SLPROWEB OpenSSL](https://slproweb.com/products/Win32OpenSSL.html) (Version 3.x Light is recommended).
    2. During installation, select **"The OpenSSL /bin directory"** when asked where to copy DLLs.
    3. Note your installation path (usually `C:\Program Files\OpenSSL-Win64\bin`).

* **Option B: Using Chocolatey**
    If you use Chocolatey, run:
    ```powershell
    choco install openssl
    ```

### 2. Configure OpenSSL Path in Code
If your OpenSSL is installed in a custom directory, you must update the path in the source code so the script can locate the `legacy` providers.

**File:** `src/Classes/CipherBase.psm1`
Update the path in the class constructor:

```powershell
class CipherBase {
    ...
    CipherBase([string]$name, [int]$keySize, [bool]$isLegacy) {
        $this.AlgorithmName = $name
        $this.KeySize = $keySize
        $this.IsLegacy = $isLegacy
        
        # ⚠️ Update this path if yours is different
        $this.ProviderPath = "C:\Program Files\OpenSSL-Win64\bin"
    }
}