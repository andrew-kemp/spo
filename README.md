# SPO PowerShell Scripts

This repository contains PowerShell scripts to assist with SharePoint Online (SPO) administration, including certificate creation for PnP PowerShell authentication and automated collection of file/folder counts across all site collections.

## Scripts

### 1. Create-PNPCert.ps1

Creates a self-signed certificate for use with PnP PowerShell or SharePoint Online automation.  
It exports both the `.cer` (public) and `.pfx` (private) keys to the specified folder.

**Usage:**

```powershell
.\Create-PNPCert.ps1
```

- You will be prompted for a secure password to protect the PFX file.
- Certificate files will be generated in `C:\certs` by default.

**Output:**
- `C:\certs\PnPAppCert.pfx`
- `C:\certs\PnPAppCert.cer`

_You may edit variables at the top of the script to change the folder or certificate subject._

---

### 2. Get-SPOFolderCount.ps1

Connects to all SharePoint Online site collections in your tenant (excluding OneDrive and App Catalog by default), enumerates all document libraries (including subsites), and outputs the total file and folder count per web to a CSV file.

#### Features

- Checks and installs PowerShell 7+ if required.
- Installs or updates the PnP.PowerShell module.
- Uses certificate authentication for best security.
- Recursively processes all site collections and subsites.
- Outputs results to a CSV file (`PnP_SPO_FileFolderCounts.csv` by default).

#### Prerequisites

- PowerShell 7.0+ (the script will attempt to install it if missing, using `winget`)
- PnP.PowerShell module (installed or updated automatically)
- A valid Azure AD App registration (ClientId) with permissions to the SPO tenant
- Self-signed certificate (generated with `Create-PNPCert.ps1`)
- Access to your SPO tenant admin URL

#### Usage

1. Generate a certificate using `Create-PNPCert.ps1` if you haven't already.
2. Ensure the variables at the top of `Get-SPOFolderCount.ps1` are set for your environment (TenantAdminUrl, ClientId, TenantDomain, CertificatePath, OutputCsv).
3. Run the script in PowerShell 7:

```powershell
pwsh .\Get-SPOFolderCount.ps1
```

4. When prompted, enter the password used to protect your PFX certificate.

5. After completion, results are saved to `PnP_SPO_FileFolderCounts.csv`.

#### Output

The CSV file will include:
- SiteUrl
- SiteTitle
- FileCount
- FolderCount

---

## Requirements

- **PowerShell 7.0 or later**
- **PnP.PowerShell** module
- **Azure AD App Registration** with the correct permissions
- **Self-signed certificate** for authentication

## License

MIT

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Author

Andrew Kemp
