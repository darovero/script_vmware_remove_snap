Connect-VIserver $viserver -User "administrator@vsphere.local" -Password "Passw0rd."


# Define the path where the information is stored
$loc = "C:\VMware_Snap\"
# Define the file name with extension .txt
$doc = "VMware_Snap.txt"
# Define date
$today = Get-Date -format “yyyy-MM-dd:hh-mm” 

Start-Transcript -Path $loc’remove_snap_log.txt’ -Append

# CREATE FOLDER WHERE THE INFORMATION WILL BE STORED
if ((Test-Path -Path $loc -PathType Container) -eq $false) {New-Item -Type Directory -Force -Path $loc}


Write-Output "Starting the script to remove VMware Snapshot" $today "`n" | Out-File $loc$doc -Append
Write-Output "The following are the VMs that have Snapshots:" $today "`n" | Out-File $loc$doc -Append
Get-VM | Get-Snapshot | select vm,vmid,name,created,SizeMB | Out-File $loc$doc -Append



$vms_snap = Get-VM  | Get-Snapshot | Where-Object { $_.Created -lt (Get-Date).AddMinutes(-5) } 
Write-Output "The following VMs meet the criteria defined by the company to remove the Snapshot" | Out-File $loc$doc -Append
Write-Output $vms_snap | select vm,vmid,name,created,SizeMB | Out-File $loc$doc -Append
ForEach ($vm in $vms_snap) {
	Remove-Snapshot -Snapshot $vm -Confirm:$false
				}

Write-Output "********************************************************************************" | Out-File $loc$doc -Append

Stop-Transcript