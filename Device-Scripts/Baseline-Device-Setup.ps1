# Parameters for script
param([String]$InstallerPath="C:\", [String]$BackgroundImage="C:\Loyal-Source.jpg")

# Baseline device setup script
Write-Host "Starting baseline setup." -ForegroundColor Magenta

# Disable security questions for local accounts
REG ADD "HKLM\Control Panel\Desktop" /v NoLocalPasswordResetQuestions /t REG_DWORD /d "1" /f

# Change registry location of wallpaper and update system params
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d $BackgroundImage /f
Start-Sleep -s 10
rundll32.exe user32.dll, UpdatePerUserSystemParameters, 0, $false
Write-Host "Background has been changed." -ForegroundColor Green

# Change legal notice
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value "CUI DATA - WARNING NOTICE"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value "This system is for the use of authorized users only. Individuals using this computer system without authority, or in excess of their authority, are subject to having all of their activities on this system monitored and recorded by system personnel. In the course of monitoring individuals improperly using this system, or in the course of system maintenance, the activities of authorized users may also be monitored.  If you are unauthorized, terminate access now."
Write-Host "Legal notice has been modified." -ForegroundColor Green

# Disable show password on logon
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" -Name "DisablePasswordReveal" -Value 1
Write-Host "Reveal password has been disabled." -ForegroundColor Green

# Disable ability to change screensaver settings, set screen saver active and changes timeout to 10 minutes - needs to be tested
REG ADD "HKCU\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d "1" /f
REG ADD "HKCU\Control Panel\Desktop" /v LockScreenAutoLockActive /t REG_SZ /d "1" /f
REG ADD "HKCU\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d "600" /f
REG ADD "HKCU\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d "1" /f
REG ADD "HKCU\Control Panel\Desktop" /v SCRNSAVE.EXE /t REG_SZ /d "C:\\Windows\\System32\\scrnsave.scr" /f

REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d "1" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v LockScreenAutoLockActive /t REG_SZ /d "1" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d "600" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d "1" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v SCRNSAVE.EXE /t REG_SZ /d "C:\\Windows\\System32\\scrnsave.scr" /f

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "NoDispScrSavPage" -Value 1
Write-Host "Screen saver settings have been modified." -ForegroundColor Green

# Sync time - needs to be tested
w32tm /config /syncfromflags:MANUAL /manualpeerlist:time.nist.gov
w32tm /config /update
w32tm /resync
Write-Host "Timezone has been synced." -ForegroundColor Green

# Disable USB devices
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\USBSTOR" -Name "Start" -Value 4
Write-Host "USB devices have been disabled." -ForegroundColor Green

# Remove unwanted programs (bloatware)
Get-AppxPackage *3dbuilder* | Remove-AppxPackage
Get-AppxPackage *3dviewer* | Remove-AppxPackage
Get-AppxPackage *getstarted* | Remove-AppxPackage
Get-AppxPackage *zunemusic* | Remove-AppxPackage
Get-AppxPackage *windowsmaps* | Remove-AppxPackage
Get-AppxPackage *solitairecollection* | Remove-AppxPackage
Get-AppxPackage *bingfinance* | Remove-AppxPackage
Get-AppxPackage *zunevideo* | Remove-AppxPackage
Get-AppxPackage *bingnews* | Remove-AppxPackage
Get-AppxPackage *windowsphone* | Remove-AppxPackage
Get-AppxPackage *photos* | Remove-AppxPackage
Get-AppxPackage *windowsstore* | Remove-AppxPackage
Get-AppxPackage *bingsports* | Remove-AppxPackage
Get-AppxPackage *soundrecorder* | Remove-AppxPackage
Get-AppxPackage *bingweather* | Remove-AppxPackage
Get-AppxPackage *xbox* | Remove-AppxPackage
Write-Host "Removed bloatware from device." -ForegroundColor Green

# Install Chrome on device
$ChromeInstaller = "chrome_installer.exe"
Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $InstallerPath\$ChromeInstaller
Start-Process -FilePath $InstallerPath\$ChromeInstaller -Args "/silent /install" -Verb RunAs -Wait
Remove-Item $InstallerPath\$ChromeInstaller
Write-Host "Chrome has been installed." -ForegroundColor Green

# Install drive filestream
$DriveInstaller = "googledrivefilestream.exe"
Invoke-WebRequest "http://dl.google.com/drive-file-stream/googledrivefilestream.exe" -OutFile $InstallerPath\$DriveInstaller
Start-Process -FilePath $InstallerPath\$DriveInstaller -Args "/silent /install" -Verb RunAs -Wait
Remove-Item $InstallerPath\$DriveInstaller
Write-Host "Google FileStream has been installed." -ForegroundColor Green

# Install Vonage on device
$VonageInstaller = "VonageBusinessSetupPerMachine.msi"
Invoke-WebRequest "http://s3.amazonaws.com/vbcdesktop.vonage.com/prod/win/VonageBusinessSetupPerMachine.msi" -OutFile $InstallerPath\$VonageInstaller
Start-Process msiexec.exe -Wait -ArgumentList "/I $InstallerPath\$VonageInstaller /quiet /norestart"
Remove-Item $InstallerPath\$VonageInstaller
Write-Host "Vonage has been installed." -ForegroundColor Green

# Install Fortinet - needs to be tested
$FortinetArchive = "FortiClientSetup_6.4.1.1519_x64.zip"
Invoke-WebRequest "http://d3gpjj9d20n0p3.cloudfront.net/forticlient/downloads/FortiClientSetup_6.4.1.1519_x64.zip" -OutFile $InstallerPath\$FortinetArchive
Expand-Archive -LiteralPath "$InstallerPath\$FortinetArchive" -DestinationPath "$InstallerPath"
Start-Process msiexec.exe -Wait -ArgumentList "/I $InstallerPath\FortiClient.msi /quiet /norestart"
Remove-Item $InstallerPath\$FortinetArchive
Write-Host "Fortinet has been installed." -ForegroundColor Green

# Install Office

# Install phish alert KnowBe4
# Need to be completed with local msi and serial key

# Complete
Write-Host "Settings changed, script now complete. Please restart your machine to finalize changes." -ForegroundColor Magenta
Read-Host "Please enter any key to close this script"
