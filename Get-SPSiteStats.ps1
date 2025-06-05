# === CONFIGURE THESE VARIABLES ===
$TenantAdminUrl = "https://kempy-admin.sharepoint.com"
$ClientId = "de9cc41f-05d3-479d-af33-cc74e8d38e6b"
$TenantDomain = "kempy.onmicrosoft.com"
$CertificatePath = "C:\certs\PnPAppCert.pfx"
$CertificatePassword = "123456" # Replace with your real PFX password
$OutputCsv = "PnP_SPO_FileFolderCounts.csv"

# --- Convert password to SecureString
$SecureCertPassword = ConvertTo-SecureString $CertificatePassword -AsPlainText -Force

# --- Connect to SharePoint Admin to get all site collections
Connect-PnPOnline `
    -Url $TenantAdminUrl `
    -ClientId $ClientId `
    -Tenant $TenantDomain `
    -CertificatePath $CertificatePath `
    -CertificatePassword $SecureCertPassword

# --- Get all site collections (excluding OneDrive and App Catalog by default)
$sites = Get-PnPTenantSite | Where-Object { 
    $_.Url -notmatch "-my\.sharepoint\.com" -and
    $_.Url -notmatch "/sites/appcatalog" 
}

$results = @()

foreach ($site in $sites) {
    try {
        # Connect to each site using certificate authentication
        Connect-PnPOnline `
            -Url $site.Url `
            -ClientId $ClientId `
            -Tenant $TenantDomain `
            -CertificatePath $CertificatePath `
            -CertificatePassword $SecureCertPassword

        # Get all visible document libraries
        $lists = Get-PnPList | Where-Object { $_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $false }

        $siteFiles = 0
        $siteFolders = 0

        foreach ($list in $lists) {
            $items = Get-PnPListItem -List $list.Title -PageSize 1000 -Fields "FileSystemObjectType"
            $siteFiles   += ($items | Where-Object { $_.FileSystemObjectType -eq "File" }).Count
            $siteFolders += ($items | Where-Object { $_.FileSystemObjectType -eq "Folder" }).Count
        }

        $results += [PSCustomObject]@{
            SiteUrl     = $site.Url
            FileCount   = $siteFiles
            FolderCount = $siteFolders
        }
        Write-Host "Processed $($site.Url): $siteFiles files, $siteFolders folders"
    }
    catch {
        Write-Warning "Failed to process site: $($site.Url). Error: $_"
    }
}

# --- Export results to CSV
$results | Export-Csv -Path $OutputCsv -NoTypeInformation

Write-Host "Export complete. File saved as $OutputCsv"
