param(
    [Parameter(Mandatory)][string] $RegistrationToken
)

$PostJoinScriptUrl = 'https://raw.githubusercontent.com/offsite-dev/avd-scripts/refs/heads/main/install-avd.ps1'
$flagPath = "C:\Windows\Temp\PreJoinSetupDone.flag"
$ErrorActionPreference = 'Stop'

# If flag exists, skip all
if (Test-Path $flagPath) {
    Write-Output "PreJoinSetup already completed. Skipping."
    exit 0
}

# Run firewall disable script
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Prepare PostJoinSetup.ps1 for scheduled task
$localScriptPath = "C:\Windows\Temp\PostJoinSetup.ps1"
Invoke-WebRequest -Uri $PostJoinScriptUrl -OutFile $localScriptPath

# Register scheduled task to run once at startup
$taskName = "AVD-PostJoinSetup"
$escapedArgs = "-ExecutionPolicy Bypass -File `"$localScriptPath`" -RegistrationToken `"$RegistrationToken`""
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $escapedArgs
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal

# Set flag so it doesn't re-run next time
New-Item -Path $flagPath -ItemType File -Force
