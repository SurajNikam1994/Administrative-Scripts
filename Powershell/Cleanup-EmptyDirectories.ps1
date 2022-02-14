#!!! High Risk Script - Involves directory deletion, kindly test in dev env before using in prod !!!

function Remove-EmptyFolder ($obj, [int]$Depth = 4)
{
    for ($i = 0; $i -lt $Depth; $i++)
    { 
            Write-Host "Iterating counter: $i `n"
            foreach ($o in $obj)
            {
                if ($(Get-Item -Path $o.Fullname -ErrorAction SilentlyContinue).Attributes -eq 'Directory')
                {
                    Write-Host -ForegroundColor Green "$($o.Name) is a directory."

                    $state = Get-ChildItem $o.Fullname
                    if ($null -eq $state)
                    {
                        Write-Host "Folder $o is empty. Deleting $o" -ForegroundColor Red
                        Remove-Item -Path $o.Fullname -Force
                    }
                    else
                    {
                        Write-Host "Folder $o is not empty, Looping inside $o"
                        Remove-EmptyFolder -obj $(gci $o.Fullname)
                    }
                }
                else
                {
                    Write-Host "Found a file $o, Ignoring and Proceeding further"
                }
            }
    }

}
$path = Read-Host "Enter the path to cleanup"
$Children = gci $path
Remove-EmptyFolder -obj $Children

