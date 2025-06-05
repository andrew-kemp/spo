# Prerequisite checks and installation
Write-Host "Checking PowerShell version..."
$requiredVersion = [Version]"7.0.0"
$currentVersion = $PSVersionTable.PSVersion

if ($currentVersion -lt $requiredVersion) {
    Write-Host "PowerShell 7+ is required. Attempting to install via winget..."
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Microsoft.Powershell --source winget --accept-package-agreements --accept-source-agreements
        Write-Host "Please restart this script in PowerShell 7 (pwsh.exe) after installation."
        exit 1
    } else {
        Write-Warning "winget is not available. Please install PowerShell 7 manually from https://aka.ms/powershell"
        exit 1
    }
} else {
    Write-Host "PowerShell 7+ is present."
}

# Ensure PnP.PowerShell module is installed and updated
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Host "PnP.PowerShell module not found. Installing..."
    Install-Module -Name PnP.PowerShell -Force -Scope CurrentUser
} else {
    Write-Host "PnP.PowerShell module found. Checking for updates..."
    Update-Module -Name PnP.PowerShell -Force -Scope CurrentUser
}

Import-Module PnP.PowerShell

# === CONFIGURE THESE VARIABLES ===
$TenantAdminUrl = "https://kempy-admin.sharepoint.com"
$ClientId = "de9cc41f-05d3-479d-af33-cc74e8d38e6b"
$TenantDomain = "kempy.onmicrosoft.com"
$CertificatePath = "C:\certs\PnPAppCert.pfx"
$OutputCsv = "PnP_SPO_FileFolderCounts.csv"

# --- Prompt for the certificate password at runtime
$SecureCertPassword = Read-Host "Enter certificate password" -AsSecureString

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
        # Connect to each site collection
        Connect-PnPOnline `
            -Url $site.Url `
            -ClientId $ClientId `
            -Tenant $TenantDomain `
            -CertificatePath $CertificatePath `
            -CertificatePassword $SecureCertPassword

        # Gather all webs (root + all subsites)
        $webs = @()
        $rootWeb = Get-PnPWeb
        $webs += $rootWeb
        $webs += Get-PnPSubWeb -Recurse

        foreach ($web in $webs) {
            # Connect to the web
            Connect-PnPOnline `
                -Url $web.Url `
                -ClientId $ClientId `
                -Tenant $TenantDomain `
                -CertificatePath $CertificatePath `
                -CertificatePassword $SecureCertPassword

            # Get the web title (works for root and subsites)
            $siteTitle = (Get-PnPWeb).Title

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
                SiteUrl     = $web.Url
                SiteTitle   = $siteTitle
                FileCount   = $siteFiles
                FolderCount = $siteFolders
            }
            Write-Host "Processed $($web.Url): $siteFiles files, $siteFolders folders"
        }
    }
    catch {
        Write-Warning "Failed to process site: $($site.Url). Error: $_"
    }
}

# --- Export results to CSV
$results | Export-Csv -Path $OutputCsv -NoTypeInformation

Write-Host "Export complete. File saved as $OutputCsv"
