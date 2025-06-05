# Set variables
$certFolder = "C:\certs"
$certSubject = "CN=PnPAppCert"
$pfxPath = Join-Path $certFolder "PnPAppCert.pfx"
$cerPath = Join-Path $certFolder "PnPAppCert.cer"

# Prompt for the PFX password securely
$pfxPassword = Read-Host "Enter a strong password to protect your PFX file" -AsSecureString

# Create cert folder if it doesn't exist
if (!(Test-Path -Path $certFolder)) {
    New-Item -ItemType Directory -Path $certFolder | Out-Null
    Write-Host "Created certificate folder at $certFolder"
}

# Create self-signed certificate
$cert = New-SelfSignedCertificate `
    -Subject $certSubject `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -KeyExportPolicy Exportable `
    -KeySpec Signature `
    -NotAfter (Get-Date).AddYears(2)

# Export public key (.cer)
Export-Certificate -Cert $cert -FilePath $cerPath

# Export private key (.pfx) with the password you entered
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $pfxPassword

Write-Host "Certificate files exported to $certFolder"
