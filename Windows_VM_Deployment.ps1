# T/S Notes
# If you are getting an error about NTCreateFile, Make sure vboxsup is enabled via `sc.exe query vboxsup` if its STOPPED, then run `sc.exe start vboxsup`

# Questions
$VMName = Read-Host "What is the name of the VM?"
$VMCPUs = Read-Host "How many CPU's would you like to provide?"
$VMMemory = Read-Host "Enter the amount of RAM in MB, 8000MB = 8GB [Min reccomended for Windows10 is 8GB]"
$VMMemSize = $VMMemory * 1024
$VMDisk = Read-Host "Enter the disk size in GB [Min reccomended for Windows10 is 32GB]"
$VMPath = "$env:USERPROFILE\VirtualBox VMs\$VMName"

Set-ExecutionPolicy Bypass -Scope Process -Force

# Grab .ISO
Add-Type -AssemblyName System.Windows.Forms
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.Filter = "ISO files (*.iso)|*.iso"
$OpenFileDialog.Title = "Select Windows ISO File"
$null = $OpenFileDialog.ShowDialog()
$ISOPath = $OpenFileDialog.FileName
if (-not $ISOPath) {
    Write-Host "Please choose a proper .ISO file."
    exit
}

# VBoxManage [This is the default path of vboxmanage when Virtualbox is installed, change if you need to.]
$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
& "$VBoxManage" createvm --name "$VMName" --ostype Windows10_64 --register
& "$VBoxManage" modifyvm "$VMName" --memory $VMMemory --vram 128 --cpus $VMCPUs --nic1 nat
& "$VBoxManage" createhd --filename "$vmPath\$VMName.vdi" --size ($VMDisk)
& "$VBoxManage" storagectl "$VMName" --name "SATA Controller" --add sata --controller IntelAhci
& "$VBoxManage" storageattach "$VMName" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VMPath\$VMName.vdi"
& "$VBoxManage" storageattach "$VMName" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$ISOPath"
& "$VBoxManage" modifyvm "$VMName" --boot1 disk --boot2 dvd --boot3 none --boot4 none
& "$VBoxManage" startvm "$VMName"
