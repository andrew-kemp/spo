# SPO Scripts

This repository contains PowerShell scripts to assist with SharePoint Online (SPO) automation and certificate management.

## Scripts

### 1. `Create-PNPCert.ps1`

Creates a self-signed certificate for use with PnP PowerShell or SharePoint Online automation.  
It exports both the `.cer` (public) and `.pfx` (private) keys to the specified folder.

#### Usage

```powershell
.\Create-PNPCert.ps1
```

You will be prompted to enter a secure password for the PFX file.  
The script will generate and export the certificate files to `C:\certs` (by default).

#### Output

- `C:\certs\PnPAppCert.pfx`
- `C:\certs\PnPAppCert.cer`

#### Customization

You may edit the variables at the top of the script to change the folder or certificate subject.

---

### 2. `Get-SPOFolderCount.ps1`

*(Currently, this script is identical to `Create-PNPCert.ps1`. If you have a folder-counting script, please update this section with its purpose and usage.)*

---

## Requirements

- Windows PowerShell 5.1 or later
- Permission to create self-signed certificates

## License

MIT

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Author

Andrew Kemp
