# storage path = "\\<storageaccount>.file.core.windows.net\profiles"
param (
    [Parameter(Mandatory = $true)]
    [string]$StoragePath 
)

# Ensure FSLogix registry path exists
$regPath = "HKLM:\SOFTWARE\FSLogix\Profiles"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# FSLogix Settings
New-ItemProperty -Path $regPath -Name "Enabled" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $regPath -Name "DeleteLocalProfileWhenVHDShouldApply" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $regPath -Name "VHDLocations" -Value $storagePath -PropertyType String -Force
New-ItemProperty -Path $regPath -Name "AccessNetworkAsComputerObject" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $regPath -Name "FlipFlopProfileDirectoryName" -Value 1 -PropertyType DWORD -Force

# Optional: Add credentials to Credential Manager for SYSTEM (if using access key instead of Kerberos)
# $storageAcct = "<storageaccount>.file.core.windows.net"
# $accessKey = "<storage_account_key>"

# cmd.exe /c "cmdkey /add:$storageAcct /user:localhost\$storageAcct /pass:$accessKey"