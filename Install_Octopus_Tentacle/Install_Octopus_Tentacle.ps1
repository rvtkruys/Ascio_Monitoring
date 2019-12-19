<#
.SYNOPSIS
    Installing and configuring the Octopus Tentacle

.DESCRIPTION
    WARNING: DO NOT PUBLISH THIS SCRIPT TO THE PUBLIC. IT CONTAINS COMPANY INFORMATION.

    This script will download the installation file from Octopus Downloads and install it according to the specifications of the Ascio 
    Octopus environment. Once installed, the script will configure and connect the Octopus Tentacle service to the Ascio Octopus console.
    Once the installation process is completed, all temporary settings to gain access to the Internet will be reversed.

    Copy the script in C:\Scripts

.PARAMETER $serverThumbprint
    If this script is used in environments other than Ascio, change the thumbprint which is unique to your Octopus environment. This thumbprint
    will change after a successful connection and integration with the Octopus Management Console.

.PARAMETER $serverUri
    If this script is used in environments other than Ascio, change the URL which is unique to your Octopus Management server.

.PARAMETER $tentacleInstallApiKey
    If this script is used in environments other than Ascio, change the API Key which is unique to your Octopus environment.

.INPUTS
    Role ID and Environment ID

.OUTPUTS
    None

.NOTES
    Version: 1.0.3
    Author: Roland van 't Kruijs
    Creation Date: 10/4/2019
    Purpose/Change: Initial script development

.EXAMPLE
    Run this script by using an administrative account on the server. Provide the Role ID and Environment ID in all caps and start the 
    installation. This process takes less than one minute to complete.
#>

Clear-Host

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

$serverThumbprint = "123A4BCDEFGHIJ56K789L0123M45N6OPQ7890RS1"
$serverUri = "http://server.contoso.com"
$tentacleInstallApiKey = "API-12ABC3DEFGHI456JKLMN7OP8QR"
$role = Read-Host -Prompt 'Provide the Role ID (all caps)'
$environment = Read-Host -Prompt 'Provide the Environment ID (all caps)'
$path = "C:\Tools"
$reg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

Clear-Host

function Tentacle-Configure([string]$arguments)
{
    #Write-Output "Configuring Tentacle with $arguments"

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe"
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.CreateNoWindow = $true; 
    $pinfo.UseShellExecute = $false;
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $arguments
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    
    Write-Host $stdout -ForegroundColor Yellow
    Write-Host $stderr -ForegroundColor Red
    
    if ($p.ExitCode -ne 0) {
        Write-Host "Exit code: " + $p.ExitCode
        throw "Configuration failed"
    }
}

function Get-ExternalIP {
    return (Invoke-WebRequest http://myexternalip.com/raw).Content.TrimEnd()
}

Write-Host "[OCTOPUS TENTACLE INSTALLATION]"

If(!(Test-Path $path)){
    New-Item -ItemType Directory -Force -Path $path
}

Set-ItemProperty -Path $reg -Name ProxyServer -Value "outboundproxy.ascio.loc:9002"
Set-ItemProperty -path $reg -Name ProxyOverride -Value "<local>*.ascio.loc"
Set-ItemProperty -Path $reg -Name ProxyEnable -Value 1

Write-Host "Downloading latest Octopus Tentacle MSI..." -ForegroundColor Yellow

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$downloader = new-object System.Net.WebClient
$downloader.DownloadFile("https://octopus.com/downloads/latest/OctopusTentacle64", "$path\Tentacle.msi")

Write-Host "Installing Octopus Tentacle..." -ForegroundColor Yellow
$msiExitCode = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $path\Tentacle.msi /quiet" -Wait -Passthru).ExitCode
if ($msiExitCode -ne 0) {
    Write-Host "Tentacle MSI installer returned exit code $msiExitCode" -ForegroundColor Red
    throw "Installation aborted"
}

Write-Host "Configuring Octopus Tentacle..." -ForegroundColor Yellow

Tentacle-Configure "create-instance --instance `"Tentacle`" --config `"C:\Octopus\Tentacle.config`" --console"
Tentacle-Configure "new-certificate --instance `"Tentacle`" --if-blank --console"
Tentacle-Configure "configure --instance `"Tentacle`" --reset-trust --console"
Tentacle-Configure "configure --instance `"Tentacle`" --home `"C:\Octopus`" --app `"C:\Ascio`" --port `"10933`" --console"
Tentacle-Configure "configure --instance `"Tentacle`" --trust `"$serverThumbprint`" --console"
Tentacle-Configure "register-with --instance `"Tentacle`" --server `"$serverUri`" --apiKey=`"$tentacleInstallApiKey`" --role `"$role`" --environment `"$environment`" --comms-style TentaclePassive --force --console"
Tentacle-Configure "service --instance `"Tentacle`" --restart"
Tentacle-Configure "service --instance `"Tentacle`" --install --start --console"
Tentacle-Configure "watchdog --create --instances *"

Write-Host "Cleaning up installation files and settings..." -ForegroundColor Yellow

Remove-ItemProperty -Path $reg -Name ProxyServer
Remove-ItemProperty -Path $reg -Name ProxyOverride
Set-ItemProperty -Path $reg -Name ProxyEnable -Value 0
Remove-Item "$path\Tentacle.msi"
Remove-Item $PSCommandPath

# Restoring the execution policies for each scope back to original state
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process -Force
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser -Force
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

Write-Host "Installation Octopus Tentacle completed..." -ForegroundColor Green