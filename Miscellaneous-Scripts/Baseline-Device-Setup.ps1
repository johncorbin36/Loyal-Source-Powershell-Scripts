
# Baseline device setup script
Write-Host "Starting baseline setup." -ForegroundColor Magenta

# Change legal notice
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value "CUI DATA - WARNING NOTICE"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value "This system is for the use of authorized users only. Individuals using this computer system without authority, or in excess of their authority, are subject to having all of their activities on this system monitored and recorded by system personnel. In the course of monitoring individuals improperly using this system, or in the course of system maintenance, the activities of authorized users may also be monitored.  If you are unauthorized, terminate access now."
Write-Host "Legal notice has been modified." -ForegroundColor Green

# Disable show password on logon
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" -Name "DisablePasswordReveal" -Value 1
Write-Host "Show password has been disabled." -ForegroundColor Green

# Disable ability to change screensaver settings
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "NoDispScrSavPage" -Value 1
Write-Host "User ability to change screen saver settings disabled." -ForegroundColor Green

# Sync time with gov
# Set-TimeZone -Id ""

# Disable USB devices
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR" -Name "Start" -Value 4
Write-Host "USB devices have been disabled." -ForegroundColor Green

# Complete
Write-Host "Settings changed, script now complete." -ForegroundColor Magenta
Read-Host "Please enter any key to close this script"
