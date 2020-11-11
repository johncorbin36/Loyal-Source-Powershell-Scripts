# Check if modules need to be installed
if (-Not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) { Install-Module -Name ExchangeOnlineManagement } 
if (-Not (Get-Module -ListAvailable -Name MSOnline)) { Install-Module -Name MSOnline } 

# Set credentials
$UserLogin = 'EMAIL_LOGIN'
$PasswordLogin = 'PASSWORD_LOGIN'
$PasswordSecure = ConvertTo-SecureString -String $PasswordLogin -AsPlainText -Force
$Login = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserLogin, $PasswordSecure

# Login to script dependencies 
Connect-MsolService -Credential $Login
Connect-ExchangeOnline -Credential $Login

# Get all inactive users (2 weeks inactive)
Write-Host "Gathering inactive users. This might take a while."
$InactiveUsers = Get-Mailbox -Resultsize Unlimited| Get-MailboxStatistics | where {$_.LastLogonTime -lt ((Get-Date).AddDays(-14))} | Select DisplayName, LastLogonTime

# Delete CSV for user data and create new CSV
if (Test-Path "C:\temp\InactiveLicensedUsers.csv") { Remove-Item "C:\temp\InactiveLicensedUsers.csv" }
$FilePath = "C:\temp\InactiveLicensedUsers.csv"
Add-Content -Path $FilePath -Value '"Name","Email","Last Log-On Date","License"'

# For each inactive user
foreach ($User in $InactiveUsers) {
        
        # Get users email
        $Email = Get-User -Identity $User.DisplayName

        # Get users licenses
        $LicensedUser = Get-MsolUser -UserPrincipalName $Email.UserPrincipalName
        $Licenses = $LicensedUser.Licenses
        $AssignedLicenses = $Licenses | foreach-Object {$_.AccountSkuId}

        # Create printable string
        $LicenseString = ''
        foreach ($License in $AssignedLicenses) {
                if ($License -eq 'reseller-account:EXCHANGESTANDARD') { $LicenseString = "Exchange Online (Plan 1) ${LicenseString}"}
                if ($License -eq 'reseller-account:O365_BUSINESS_ESSENTIALS') { $LicenseString = "Microsoft 365 Business Basic ${LicenseString}"}
                if ($License -eq 'reseller-account:O365_BUSINESS') { $LicenseString = "Microsoft 365 Apps for Business ${LicenseString}"}
                if ($License -eq 'reseller-account:ENTERPRISEPACK') { $LicenseString = "Office 365 E3 ${LicenseString}"}
        }

        # Add data to CSV 
        if ($LicenseString -ne '') {
                $Value = "{0},{1},{2},{3}" -f $User.DisplayName,$Email.UserPrincipalName,$User.LastLogonTime,$LicenseString
                Add-Content -Path $FilePath -Value $Value
        }

}

# Mail variables
$MailFrom = "EMAIL_FROM"
$MailTo = "EMAIL_TO"

$SmtpServer = "outlook.office365.com"
$SmtpPort = 587

$Subject = "Monthly Report of Licensed Inactive Users"
$Body = "Attached is the monthly licensed inactive users report."
$Attachment = "${FilePath}"

# Send email
Send-MailMessage -From $MailFrom -to $MailTo -Subject $Subject `
-Body $Body -SmtpServer $SmtpServer -port $SmtpPort `
-Credential $Login -UseSsl -Attachment $Attachment

# Complete
Write-Host 'Complete'
