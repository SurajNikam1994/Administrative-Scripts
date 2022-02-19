$server = Read-Host "Enter the Hostname or IP"
$SWserver = Read-Host "Enter the Solarwinds Server IP or Hostname"
$Communitystring = Read-Host "Enter the Community String"

Invoke-Command -ComputerName $server -ScriptBlock {Get-WindowsFeature -Name snmp* | Install-WindowsFeature -IncludeAllSubFeature -IncludeManagementTools}
$Test1 = Invoke-Command -ComputerName $server -ScriptBlock {Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities"}
$Test2 = Invoke-Command -ComputerName $server -ScriptBlock {Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers"}

if($Test1 -eq $true -and $Test2 -eq $true)
{
    Invoke-Command -ComputerName $server -ScriptBlock {param($Communitystring) New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\ValidCommunities" -Name $Communitystring -PropertyType "DWORD" -Value 4} -ArgumentList $Communitystring
    Invoke-Command -ComputerName $server -ScriptBlock {param($SWserver) New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" -Name $SWserver -PropertyType "string" -Value $SWserver} -ArgumentList $SWserver
    gsv -ComputerName $server -Name "SNMP Service" | Restart-Service
    Write-Host "SNMP installation and configuration completed with Allowed hostname: $($SWserver) and Community String $($Communitystring) for server $($server)." -ForegroundColor Green
}

else
{
    Write-Host -ForegroundColor Red "Failed to fetch SNMP parameters path for $($server). Check the settings manually!"
}
