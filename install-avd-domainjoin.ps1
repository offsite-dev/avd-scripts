param(
    [Parameter(Mandatory=$true)]
    [string]$Domain,

    [Parameter(Mandatory=$true)]
    [string]$OUPath,

    [Parameter(Mandatory=$true)]
    [string]$DomainJoinUser,

    [Parameter(Mandatory=$true)]
    [System.Security.SecureString]$DomainJoinPassword,

    [Parameter(Mandatory)][string] 
    $RegistrationToken
)

$flagPath = "C:\Temp\DomainJoinCompleted.txt"
$ErrorActionPreference = "Stop"

function Is-DomainJoined {
    $cs = Get-WmiObject Win32_ComputerSystem
    return $cs.PartOfDomain
}

if (-not (Test-Path $flagPath)) {
    Write-Output "Running pre-domain-join steps..."

    # Run firewall disable script
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

    if (-not (Is-DomainJoined)) {
        Write-Output "Joining domain $Domain..."
        $cred = New-Object System.Management.Automation.PSCredential($DomainJoinUser, $DomainJoinPassword)
        Add-Computer -DomainName $Domain -Credential $cred -OUPath $OUPath -ErrorAction Stop
        New-Item -Path $flagPath -ItemType File -Force
        Restart-Computer -Force
        exit 0
    }
}


# After reboot
Write-Output "Running post-domain-join steps..."

$agentUri = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
$bootloaderUri = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"
$agentPath = "$env:TEMP\avdagent.msi"
$bootloaderPath = "$env:TEMP\avdbootloader.msi"

Invoke-WebRequest -Uri $agentUri -OutFile $agentPath
Invoke-WebRequest -Uri $bootloaderUri -OutFile $bootloaderPath

Start-Process msiexec.exe -ArgumentList "/i `"$agentPath`" /quiet /qn /norestart REGISTRATIONTOKEN=$RegistrationToken" -Wait
Start-Process msiexec.exe -ArgumentList "/i `"$bootloaderPath`" /quiet /qn /norestart" -Wait

Write-Output "AVD agent install script completed. Exiting."
exit 0
