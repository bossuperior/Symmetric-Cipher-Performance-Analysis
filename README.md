# Symmetric Cipher Performance Analysis (PowerShell OOP)

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