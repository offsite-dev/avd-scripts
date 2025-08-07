param(
  [Parameter(Mandatory)][string] $RegistrationToken
)

$agentUri = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
$bootloaderUri = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"
$agentPath = "$env:TEMP\avdagent.msi"
$bootloaderPath = "$env:TEMP\avdbootloader.msi"

Invoke-WebRequest -Uri $agentUri -OutFile $agentPath
Invoke-WebRequest -Uri $bootloaderUri -OutFile $bootloaderPath

Start-Process msiexec.exe -ArgumentList "/i `"$agentPath`" /quiet /qn /norestart REGISTRATIONTOKEN=$RegistrationToken" -Wait
Start-Process msiexec.exe -ArgumentList "/i `"$bootloaderPath`" /quiet /qn /norestart" -Wait

# Disable firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
