#Initialize an array to hold Disk data for list of servers
$LocalDiskdata = @()

#Import Serverlist
$serverlist = Get-Content -Path "$env:USERPROFILE\Desktop\serverlist.txt"

#Start Looping through each server in the serverlist
foreach ($server in $serverlist)
{
  
    
    $IPAddress = (icm -ComputerName $server -ScriptBlock {Get-NetIPAddress | ?{$_.AddressFamily -eq 'IPv4' -and $_.PrefixOrigin -eq 'Manual'}}).Ipaddress
    $LocalDrives = Get-CimInstance -ComputerName $server -ClassName Win32_LogicalDisk | ?{$PSItem.DriveType -eq 3}
    foreach ($drive in $LocalDrives)
    {
        $capacity = $($drive.Size/1gb).ToString("###.#")
        $FreeSpace = $($drive.FreeSpace/1gb).ToString("###.#")
        $percent_Free = $($drive.FreeSpace/$drive.Size).ToString("P")

        $dataHash = New-Object -TypeName psobject | select @{n="Server";e={$server}}, @{n="VolumeID";e={$drive.DeviceID}}, @{n="IP";e={$IPAddress}}, @{n="capacity";e={$capacity}}, @{n="FreeSpace";e={$FreeSpace}}, @{n="Free%";e={$percent_Free}}
        $LocalDiskdata += $dataHash
    }
    $MntDrives = Get-CimInstance -ComputerName $server -ClassName Win32_Volume | ?{$_.DriveLetter -eq $null -and $_.Name -notlike "*Volume*"}
    foreach ($mnt in $MntDrives)
    {
        $mnt_capacity = $($mnt.capacity/1gb).ToString("###.#")
        $mnt_FreeSpace = $($mnt.FreeSpace/1gb).ToString("###.#")
        $mnt_percent_Free = $($mnt.FreeSpace/$mnt.capacity).ToString("P")
        $mnt_VolumeId = $($mnt.Name).Split('\')[1]

        $mnt_datahash = New-Object -TypeName psobject | select @{n="Server";e={$server}}, @{n="VolumeID";e={$mnt_VolumeId}}, @{n="IP";e={$IPAddress}}, @{n="capacity";e={$mnt_capacity}}, @{n="FreeSpace";e={$mnt_FreeSpace}}, @{n="Free%";e={$mnt_percent_Free}}
        $LocalDiskdata += $mnt_datahash

    }
}

$LocalDiskdata | Export-Csv -Path "$env:USERPROFILE\Desktop\DiskOutputs.csv" -NoTypeInformation
