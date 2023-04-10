Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force


Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'Data' -Confirm:$false 

# Install required modules
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module pswindowsupdate -force
Import-Module PSWindowsUpdate -force
# End installing required modules

#Get list of windows updates to install
Get-WindowsUpdate

#install the updates
Install-WindowsUpdate -AcceptAll -install -AutoReboot

