# Install PS module
Install-Module PSWindowsUpdate -Force

# Get asset tag
$AssetTag = Read-Host "Please enter last four digits of asset tag"

# Rename computer
Rename-Computer -NewName "LS$AssetTag"
Write-Host "Changed device name to LS$AssetTag." -ForegroundColor Green

# Create local account password
$AccountPassword = 'PASSWORD'
$AccountPasswordSecure = ConvertTo-SecureString $AccountPassword -AsPlainText -Force

# Change local account password
$LocalAdmin = Get-LocalUser -Name "ACCOUNT_NAME"
$LocalAdmin | Set-LocalUser -Password $AccountPasswordSecure
Write-Host "Changed password for local admin to $AccountPassword" -ForegroundColor Green

# Update windows
Download-WindowsUpdate -Confirm -Force
Write-Host "Updates checked and have completed installation." -ForegroundColor Green

# Gather system information and send to email (update to automatic HTTP request at later point)
$Model = $(Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Model).Model
$Manufacturer = $(Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer).Manufacturer
$Serial = $(Get-WmiObject win32_bios | Select-Object Serialnumber).Serialnumber

# Set login credentials
$UserLogin = 'EMAIL'
$PasswordLogin = 'PASSWORD'
$PasswordSecure = ConvertTo-SecureString -String $PasswordLogin -AsPlainText -Force
$Login = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserLogin, $PasswordSecure

# Mail Variables
$MailFrom = "MAIL_FROM"
$MailTo = "MAIL_TO"

$SmtpServer = "outlook.office365.com"
$SmtpPort = 587

$Subject = "DEVICE INFO FOR LS$AssetTag"
$Body = "AssetTag: LS$AssetTag `nModel: $Model `nManufacturer: $Manufacturer `nSerial: $Serial"

# Send email
Send-MailMessage -From $MailFrom -to $MailTo -Subject $Subject `
-Body $Body -SmtpServer $SmtpServer -port $SmtpPort `
-Credential $Login -UseSsl
Write-Host "Email has been sent containing device details." -ForegroundColor Green

# Run Comodo installer
$ComodoPath = "PATH_TO_INSTALLER"
Start-Process -FilePath $ComodoPath -Args "/silent /install" -Verb RunAs -Wait
Remove-Item -Path $ComodoPath
Write-Host "Comodo installer running, residual executable file has been removed." -ForegroundColor Green

# HTTP request to update Equipment log automatically, replace email
# Write-Host "Equipment log updated." -ForegroundColor Green

Write-Host "Admin script complete. Comodo will restart this device shortly." -ForegroundColor Green
Write-Host "Please continue onto the User device setup script." -ForegroundColor Green
Read-Host "Press any key to exit prompt"
