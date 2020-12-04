
# Backup password to Azure
Add-BitLockerKeyProtector -MountPoint "C:" -RecoveryPasswordProtector
$BLV = Get-BitLockerVolume -MountPoint "C:"
BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[0].KeyProtectorId

# Enable bitlocker 
Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes128 -UsedSpaceOnly -TpmProtector 
