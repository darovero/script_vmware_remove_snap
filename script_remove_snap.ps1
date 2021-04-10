################################################################################
# This script validates all snapshots of VMs in the VMware vSphere environment #
# and removes VMs that have expired within the defined time for the company    #
################################################################################

# VARIABLES

#  vCenter Server
$viserver = "vcsabp.ivti.loc"
#  User
$viuser = "administrator@vsphere.local"
#  Password
$vipass = "P4ssw0rd."
# Define the path where the information is stored
$loc = "C:\VMware_Snap\"
# Define the file name with extension .txt
$doc = "VMware_Snap.txt"
# Rename the file and add the date
$filenameFormat = "Snap_Removed" + " " + (Get-Date -Format "yyyy-MM-dd-hh-mm") + ".txt"
# Define the expiration date of the Snapshot (for example: AddMinutes for Minutes, AddHours for Hours ando AddDays for day. And change the number value that is inside the parentheses) 
$validate_time = (Get-Date).AddHours(-24)

# CREATE THE CONNECTION AND ACCESS WITH vCSA
Connect-VIserver $viserver -User $viuser -Password $vipass

Start-Transcript -Path $loc’remove_snap_log.txt’ -Append

# VMs validation with Snapshot
Write-Output "***** The following are the VMs that have Snapshots: ****" "`n" | Out-File $loc$doc -Append
$snap_validate = Get-VM | Get-Snapshot | Select-Object vm,vmid,name,created,SizeMB
if ($null -eq $snap_validate) {
     Write-Output ("No exists VMs with Snapshot")  | Out-File $loc$doc -Append
}
else {
Write-Output $snap_validate | Out-File $loc$doc -Append
}

# VMs validation with Snapshot for deleted
Write-Output "`n" "`n"  "**** The following VMs meet the criteria defined by the company to remove the Snapshot ****" "`n" "`n" | Out-File $loc$doc -Append
$vms_snap = Get-VM  | Get-Snapshot | Where-Object { $_.Created -lt $validate_time } 
if ($null -eq $vms_snap) {
     Write-Output ("No exists VMs with Snapshot for delete") | Out-File $loc$doc -Append
}
else {
Write-Output $vms_snap | Select-Object vm,vmid,name,created,SizeMB | Out-File $loc$doc -Append
}

ForEach ($vm in $vms_snap)
{
	Remove-Snapshot -Snapshot $vm -Confirm:$false
}

Rename-Item $loc$doc -NewName $filenameFormat -Force

Stop-Transcript