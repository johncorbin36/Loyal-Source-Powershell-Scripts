# Get asset tag
$AssetTag = Read-Host "Please enter last four digits of asset tag"

# Rename computer
Rename-Computer -NewName "LS$AssetTag"
Write-Host "Changed device name to LS$AssetTag." -ForegroundColor Green

# Create local account password
$AccountPassword = "PASSWORD"
$AccountPasswordSecure = ConvertTo-SecureString $AccountPassword -AsPlainText -Force

# Change local account password
$LocalAdmin = Get-LocalUser -Name "ACCOUNT_NAME"
$LocalAdmin | Set-LocalUser -Password $AccountPasswordSecure
Write-Host "Changed password for local admin to $AccountPassword" -ForegroundColor Green

# Import xml file for new user layout
Import-StartLayout -LayoutPath "PATH_TO_LAYOUT"

# Run Comodo installer
$Path = "PATH_TO_INSTALLER"
& $Path

Write-Host "Admin script complete. Please login to the user account and run the user setup script after Comodo installation is complete." -ForegroundColor Green
Read-Host "Press any key to exit prompt."
