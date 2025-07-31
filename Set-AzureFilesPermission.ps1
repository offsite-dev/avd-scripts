param(
    [string] $storageAccountName,
    [string] $fileShareName,
    [string] $securityGroup
)

$sharePath = "\\$storageAccountName.file.core.windows.net\$fileShareName"

# Map drive (optional)
New-PSDrive -Name Z -PSProvider FileSystem -Root $sharePath -Persist

# Get current ACL
$acl = Get-Acl -Path "Z:\"

# Define the access rule
$permission = "$securityGroup","Modify","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission

# Add access rule
$acl.SetAccessRule($accessRule)

# Set the updated ACL back
Set-Acl -Path "Z:\" -AclObject $acl

# Need to decide whether to remove or keep the mapping
# Remove drive mapping
Remove-PSDrive -Name Z
