# Backup password to Azure
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
$BLV = Get-BitLockerVolume -MountPoint "C:"
BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[0].KeyProtectorId
Write-Host "Backed up Bitlocker key to Azure account." -ForegroundColor Green

# Enable bitlocker 
Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes128 -UsedSpaceOnly -TpmProtector 
Write-Host "Enabled Bitlocker for drive 'C:'. Encryption will begin after restart." -ForegroundColor Green

# Enable wifi
Read-Host "Are you ready to enable wifi? Press any key to continue"
netsh wlan connect ssid="NETWORK_NAME" key="PASSWORD"

Read-Host "Script complete. Press any key to close prompt."
