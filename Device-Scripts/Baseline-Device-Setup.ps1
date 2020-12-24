# Parameters for script
param([String]$InstallerPath="C:\", [String]$BackgroundImage="C:\Loyal-Source.png")

# Baseline device setup script
Write-Host "Starting baseline setup." -ForegroundColor Magenta

# Change background and lock screen
Move-Item -Path $BackgroundImage -Destination "C:\Windows\web\wallpaper\Loyal-Source.png"

New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows" -Name Personalization -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name LockScreenImage -value "C:\Windows\web\wallpaper\Loyal-Source.png"
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Policies" -Name System -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -value "C:\Windows\web\wallpaper\Loyal-Source.png"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -value "4"

Start-Sleep -s 10
rundll32.exe user32.dll, UpdatePerUserSystemParameters, 0, $false
Write-Host "Background has been changed. Refresh the desktop if not automatically updated." -ForegroundColor Green

# Disable color scheme and background personalization
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\" -Name NoDispAppearancePage -Value "1"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop\" -Name NoChangingWallPaper -Value "1"

# Disable security questions for local accounts
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v NoLocalPasswordResetQuestions /t REG_DWORD /d "1" /f

# Change legal notice
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value "CUI DATA - WARNING NOTICE"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value "This system is for the use of authorized users only. Individuals using this computer system without authority, or in excess of their authority, are subject to having all of their activities on this system monitored and recorded by system personnel. In the course of monitoring individuals improperly using this system, or in the course of system maintenance, the activities of authorized users may also be monitored.  If you are unauthorized, terminate access now."
Write-Host "Legal notice has been modified." -ForegroundColor Green

# Disable show password on logon
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredUI" -Name "DisablePasswordReveal" -Value 1
Write-Host "Reveal password has been disabled." -ForegroundColor Green

# Disable ability to change screensaver settings, set screen saver active and changes timeout to 10 minutes
REG ADD "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d "1" /f
REG ADD "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v LockScreenAutoLockActive /t REG_SZ /d "1" /f
REG ADD "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d "1" /f
REG ADD "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v SCRNSAVE.EXE /t REG_SZ /d "C:\\Windows\\System32\\scrnsave.scr" /f
REG ADD "HKCU\Software\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d "600" /f

REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d "1" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v LockScreenAutoLockActive /t REG_SZ /d "1" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveTimeOut /t REG_SZ /d "600" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaverIsSecure /t REG_SZ /d "1" /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v SCRNSAVE.EXE /t REG_SZ /d "C:\\Windows\\System32\\scrnsave.scr" /f

Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "NoDispScrSavPage" -Value 1
Write-Host "Screen saver settings have been modified." -ForegroundColor Green

# Sync time, change time zone manually 
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
$DriveInstaller = "GoogleDriveFSSetup.exe"
Invoke-WebRequest "https://dl.google.com/drive-file-stream/GoogleDriveFSSetup.exe" -OutFile $InstallerPath\$DriveInstaller
Start-Process -FilePath $InstallerPath\$DriveInstaller -Args "/silent /install" -Verb RunAs -Wait
Remove-Item $InstallerPath\$DriveInstaller
Write-Host "Google FileStream has been installed." -ForegroundColor Green

# Install Vonage on device
$VonageInstaller = "VonageBusinessSetupPerMachine.msi"
Invoke-WebRequest "http://s3.amazonaws.com/vbcdesktop.vonage.com/prod/win/VonageBusinessSetupPerMachine.msi" -OutFile $InstallerPath\$VonageInstaller
Start-Process msiexec.exe -Wait -ArgumentList "/I $InstallerPath\$VonageInstaller /quiet /norestart"
Remove-Item $InstallerPath\$VonageInstaller
Write-Host "Vonage has been installed." -ForegroundColor Green

# Install Fortinet 
<#
$FortinetArchive = "FortiClientSetup_6.4.1.1519_x64.zip"
New-Item -Path $InstallerPath -Name "FortinetFiles" -ItemType "directory"
Invoke-WebRequest "http://d3gpjj9d20n0p3.cloudfront.net/forticlient/downloads/FortiClientSetup_6.4.1.1519_x64.zip" -OutFile $InstallerPath\$FortinetArchive
Expand-Archive -LiteralPath "$InstallerPath\$FortinetArchive" -DestinationPath "$InstallerPath\FortinetFiles"
Start-Process msiexec.exe -Wait -ArgumentList "/I $InstallerPath\FortinetFiles\FortiClient.msi /quiet /norestart"
Remove-Item $InstallerPath\$FortinetArchive
Remove-Item "$InstallerPath\FortinetFiles"
Write-Host "Fortinet has been installed." -ForegroundColor Green
#>

# Install Fortinet VPN
$FortinetExe = "FortiClientVPNOnlineInstaller_6.4.exe"
Invoke-WebRequest "http://filestore.fortinet.com/forticlient/downloads/FortiClientVPNOnlineInstaller_6.4.exe" -OutFile $InstallerPath\$FortinetExe
Start-Process -FilePath $InstallerPath\$FortinetExe -Args "/silent /install" -Verb RunAs -Wait
Remove-Item $InstallerPath\$FortinetExe
Write-Host "Fortinet VPN client has been installed." -ForegroundColor Green

# Install Office - not done
<#
$OfficeExe = "setup.exe"
New-Item -Path $InstallerPath -Name "OfficeSetup" -ItemType "directory"
Invoke-WebRequest "http://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_13426-20308.exe" -OutFile $InstallerPath\$OfficeExe
Start-Process -FilePath $InstallerPath\$OfficeExe -Args "/download downloadconfig.xml" -Verb RunAs -Wait
Start-Process -FilePath $InstallerPath\$OfficeExe -Args "/configure installconfig.xml" -Verb RunAs -Wait
Remove-Item $InstallerPath\$OfficeExe
Remove-Item "$InstallerPath\OfficeSetup"
#>

# Install phish alert KnowBe4 - need to be completed with local msi and serial key

# Complete
Write-Host "Settings changed, script now complete. Please restart your machine to finalize changes." -ForegroundColor Magenta
Read-Host "Please enter any key to close this script"
