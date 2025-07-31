
# Mounts Azure File Share as network drive
$driveLetter = "Z:"
$storageAccount = "mystorageacct"
$shareName = "fileshare"
$path = "\\$storageAccount.file.core.windows.net\$shareName"

# Mount with identity (requires domain join + AD auth configured on share)
New-PSDrive -Name $driveLetter.TrimEnd(':') -PSProvider FileSystem -Root $path -Persist
