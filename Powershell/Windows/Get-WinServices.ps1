#Purpose : Fetch service status on collection of servers remotely and export it to an excel file

[string]$serviceName = Read-Host "Please input the name of service to be queried"
$serverlist = Get-Content -Path "$env:USERPROFILE\Desktop\serverlist.txt" -ErrorAction Stop
$NA = "Not_present"
if ($null -eq $serverlist)
{
    throw "serverlist.txt does not have any content. Halting now.."
}
$globalResults = @()

foreach ($server in $serverlist)
{
    $status = Get-Service -ComputerName $server -Name $serviceName -ErrorAction Continue
    if ($status)
    {
        $serviceStat = New-Object -TypeName psobject | select @{n="Server";e={$server}}, @{n="ServiceName";e={$status.Name}}, @{n="ServiceDisplayName";e={$status.DisplayName}}, @{n="status";e={$status.Status}}, @{n="mode";e={$status.StartType}}
        $globalResults += $serviceStat
    }
    else
    {
        $serviceStat = New-Object -TypeName psobject | select @{n="Server";e={$server}}, @{n="ServiceName";e={$serviceName}}, @{n="ServiceDisplayName";e={$NA}}, @{n="status";e={$NA}}, @{n="mode";e={$NA}}
        $globalResults += $serviceStat      
    }
}

$globalResults | Export-Csv -Path "$env:USERPROFILE\Desktop\Report_$($serviceName)-$($(Get-Date).ToString('dd-MM-yyyy_hh-mm-ss')).csv" -NoTypeInformation
