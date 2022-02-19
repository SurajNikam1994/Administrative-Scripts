function Start-HealthCheck
{

    [cmdletbinding()]

        param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateCount(1,4)]
        [ValidateScript({Test-Connection -ComputerName $_ -Quiet -count 4})]
        [string[]]$computername,
        [Parameter()]
        [ValidatePattern('^[0-9]*[0-9]$')]
        [Validaterange(10,100)]
        $CpuDuration = 10,
        [Parameter()]
        [ValidatePattern('^[0-9]*[0-9]$')]
        $MemoryDuration = 10
        )

        foreach ($computername in $computername){
        
            #Getting IPAdrress
            Write-Verbose "Getting IP Details from $computername"
            $IPAddress = (icm -ComputerName $computername -ScriptBlock {Get-NetIPAddress | ?{$_.AddressFamily -eq 'IPv4' -and $_.PrefixOrigin -eq 'Manual'}}).Ipaddress

            #Getting CPU 10 samples 1 second apart
            Write-Verbose "Getting CPU Statistics from $computername"
            $cpu = "{0:N2}" -f (((Get-Counter -ComputerName $computername '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples $CpuDuration).countersamples).cookedvalue | Measure-Object -Average).Average + " %"

            #Getting Memory 5 samples 1 second apart
            Write-Verbose "Getting Physical Memory Statistics from $computername"
            $mem = "{0:N2}" -f (((Get-Counter -ComputerName $computername '\Memory\% Committed Bytes In Use' -SampleInterval 1 -MaxSamples $MemoryDuration).CounterSamples).CookedValue | Measure-Object -Average).Average + " %"

            #Getting C Drive Free Space single sample
            Write-Verbose "Getting C Drive Statistics from $computername"
            $FreeC = "{0:N2}" -f (((Get-Counter -ComputerName $computername -Counter '\LogicalDisk(C:)\% Free Space').countersamples).cookedvalue | Measure-Object -Average).Average + " %"

            #Getting Last Reboot Datetime
            Write-Verbose "Getting System Boot timestamps from $computername"
            $LastBoot = (Get-CimInstance -ComputerName $computername -ClassName cim_operatingsystem).LastBootUpTime

            #Getting Logged in User Sessions Logic Block 1
            Write-Verbose "Getting connected Remote desktop users details from $computername"
            $LoggedInUser = tasklist /s $computername /v /FI "IMAGENAME eq explorer.exe" /FO list | find "User Name:"

            #Getting OS Version
            Write-Verbose "Getting OS Details from $computername"
            $OSver = (gwmi -ComputerName $computername -Class win32_operatingsystem).caption

            #Getting Logged in User Sessions Logic Block 2
            if ($LoggedInUser -eq $null)
            {
                $UserSessions = 'No Users'
            }
            else
            {
                $UserSessions = $LoggedInUser.substring(14)
            }

            #Creating Ordered Hashtable to store previous parameters
            $result = [ordered]@{
            computername = $computername
            IPAddress = $IPAddress
            CPU = $cpu
            Memory = $mem
            FreeCspace = $FreeC
            LastReboot = $LastBoot
            UserSessions = $UserSessions
            }
        "" | Select-Object @{n="Server";e={$result.computername}},@{n="IpAddress";e={$result.IPAddress}},@{n="CPU_Usage";e={$result.CPU}},@{n="Memory_Usage";e={$result.Memory}},@{n="C_Drive_Free_Percent";e={$result.FreeCspace}},@{n="LastReboot";e={$result.LastReboot}},@{n="UserSessions";e={$result.UserSessions}}

        }
        
}
