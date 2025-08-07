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

function Is-DomainJoined {
    $cs = Get-WmiObject Win32_ComputerSystem
    return $cs.PartOfDomain
}

# Step 1: Run firewall disable script (assumed to be local path on VM)
Write-Output "Running firewall disable script: $FirewallScriptPath"
try {
    # Disable firewall
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
} catch {
    Write-Warning "Failed to disable firewall $_"
}

# Convert secure string password to credential
$cred = New-Object System.Management.Automation.PSCredential($DomainJoinUser, $DomainJoinPassword)

# Step 2: Join domain if not already joined
if (-not (Is-DomainJoined)) {
    Write-Output "Joining domain $Domain..."
    try {
        Add-Computer -DomainName $Domain -Credential $cred -OUPath $OUPath -ErrorAction Stop
        Write-Output "Domain join succeeded, rebooting now..."
        Restart-Computer -Force
        exit
    } catch {
        Write-Error "Domain join failed: $_"
        exit 1
    }
} else {
    Write-Output "Machine already domain joined."
}

# Step 3: After reboot, download and run AVD agent install script

Write-Output "Running AVD agent install script..."
try {
    $agentUri = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
    $bootloaderUri = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"
    $agentPath = "$env:TEMP\avdagent.msi"
    $bootloaderPath = "$env:TEMP\avdbootloader.msi"

    Invoke-WebRequest -Uri $agentUri -OutFile $agentPath
    Invoke-WebRequest -Uri $bootloaderUri -OutFile $bootloaderPath

    Start-Process msiexec.exe -ArgumentList "/i `"$agentPath`" /quiet /qn /norestart REGISTRATIONTOKEN=$RegistrationToken" -Wait
    Start-Process msiexec.exe -ArgumentList "/i `"$bootloaderPath`" /quiet /qn /norestart" -Wait

    Write-Output "AVD agent install script completed."
} catch {
    Write-Warning "Failed to run AVD agent script: $_"
}
