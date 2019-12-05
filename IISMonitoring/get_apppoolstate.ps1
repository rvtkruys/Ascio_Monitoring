<#
param ([string] $name = 0)
Import-Module WebAdministration
$apppoolState = Get-WebAppPoolState -name "$name"
Write-Output ($apppoolState.value)
#>

Import-Module WebAdministration
set-Location IIS:\AppPools
$ApplicationPools = dir

foreach ($item in $ApplicationPools)
{
    $ApplicationPoolName = $item.Name
    $ApplicationPoolStatus = $item.state
    $apppoolState = Get-WebAppPoolState -name $ApplicationPoolName
}

Write-Output ($apppoolState.value)