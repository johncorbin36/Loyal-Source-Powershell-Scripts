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
$MailFrom = "SEND_FROM"
$MailTo = "SEND_TO"

$SmtpServer = "outlook.office365.com"
$SmtpPort = 587

$Subject = "DEVICE INFO FOR LS$AssetTag"
$Body = "AssetTag: LS$AssetTag `nModel: $Model `nManufacturer: $Manufacturer `nSerial: $Serial"

# Send email
Send-MailMessage -From $MailFrom -to $MailTo -Subject $Subject `
-Body $Body -SmtpServer $SmtpServer -port $SmtpPort `
-Credential $Login -UseSsl
Write-Host "Email has been sent containing device details." -ForegroundColor Green