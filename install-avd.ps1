param(
  [Parameter(Mandatory)][string] $RegistrationToken
)

$flagPath = "C:\Windows\Temp\AVDAgentInstalled.flag"

Start-Transcript -Path $logFile -Append
if (Test-Path $flagPath) {
    Write-Output "AVD agent already installed. Exiting."
    Stop-Transcript
    exit 0
}

$agentUri = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
$bootloaderUri = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"
$agentPath = "$env:TEMP\avdagent.msi"
$bootloaderPath = "$env:TEMP\avdbootloader.msi"

Invoke-WebRequest -Uri $agentUri -OutFile $agentPath
Invoke-WebRequest -Uri $bootloaderUri -OutFile $bootloaderPath

Start-Process msiexec.exe -ArgumentList "/i `"$agentPath`" /quiet /qn /norestart REGISTRATIONTOKEN=$RegistrationToken" -Wait
Start-Process msiexec.exe -ArgumentList "/i `"$bootloaderPath`" /quiet /qn /norestart" -Wait

Write-Output "Installation complete. Creating flag file."
New-Item -Path $flagPath -ItemType File -Force

Stop-Transcript
exit 0
