# T/S Notes
# If you are getting an error about NTCreateFile, Make sure vboxsup is enabled via `sc.exe query vboxsup` if its STOPPED, then run `sc.exe start vboxsup`

# Current Stage of Script: The Script runs successfully but does not autocreate a user or configure installation, all of this is manual at the moment

# Questions
$VMName = Read-Host "Enter the VM name"
$VMCPUs = Read-Host "Number of CPU cores?"
$VMMemory = Read-Host "Amount of RAM in MB (e.g., 8192 = 8GB)"
$VMDisk = Read-Host "Disk size in GB (32 min)"
$VMCPUs = [int]$VMCPUs
$VMMemory = [int]$VMMemory
$VMDiskSizeMB = [int]$VMDisk * 1024
$VMPath = "$env:USERPROFILE\VirtualBox VMs\$VMName"
if (-not (Test-Path $VMPath)) {
    New-Item -ItemType Directory -Path $VMPath | Out-Null
}
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
& "$VBoxManage" modifyvm "$VMName" --memory $VMMemory --cpus $VMCPUs --vram 128 --ioapic on --boot1 dvd --nic1 nat
& "$VBoxManage" createhd --filename "$VMPath\$VMName.vdi" --size $VMDiskSizeMB
& "$VBoxManage" storagectl "$VMName" --name "SATA Controller" --add sata --controller IntelAhci
& "$VBoxManage" storageattach "$VMName" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VMPath\$VMName.vdi"
& "$VBoxManage" storageattach "$VMName" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$ISOPath"
& "$VBoxManage" startvm "$VMName" --type gui

# .ISO Detach
Write-Host "`n Once Windows says 'Restarting in a few seconds', close the VM window."
Read-Host "Press Enter once you've closed the VM to detach the ISO."
& "$VBoxManage" storageattach "$VMName" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium none
