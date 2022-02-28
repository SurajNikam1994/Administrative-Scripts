$vm = Read-Host "Enter name of the VM to change the sku for"
$sku = Read-Host "Enter the sku string"
Get-AzVM -VMName $vm | %{$_.HardwareProfile.VmSize = $sku; Update-AzVM -VM $_ -ResourceGroupName $_.ResourceGroupName}
