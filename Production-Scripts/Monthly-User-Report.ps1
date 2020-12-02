# Set params
param([Int32]$Days=30, [String]$FilePath="C:\temp\Monthly-User-Report.csv", [Bool]$InternalOnly=$true)

# Set login credentials
$UserLogin = 'LOGIN_HERE'
$PasswordLogin = 'PASSWORD_HERE'
$PasswordSecure = ConvertTo-SecureString -String $PasswordLogin -AsPlainText -Force
$Login = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserLogin, $PasswordSecure

# Login to script dependencies
Connect-ExchangeOnline -Credential $Login
Connect-MsolService -Credential $Login
Connect-AzureAD -Credential $Login

# Remove residual file and create new one
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Name","Email","Last Interaction Time","Last Log On Date","Account Disabled","Licenses","Active"'

# Iterate through each user in Azure DB
$i = 0
foreach ($User in $TotalUsers = Get-AzureADUser -All $true) {

    # Write progress
    $i++
    Write-Progress -Activity "Checking user: $($User.DisplayName)" -PercentComplete (($i / $TotalUsers.Count)* 100)

    # Set user principal name
    if ($User.UserPrincipalName -contains " ") { $UserPrincipalName = $($User.UserPrincipalName -split " ")[0] }
    else { $UserPrincipalName = $User.UserPrincipalName }

    # Check if user is internal
    if (($InternalOnly) -and (-not ($UserPrincipalName -match "DOMAIN_HERE") -or ($UserPrincipalName -match "#EXT#"))) { continue }

    # Set active bool
    $InteractionInactive = $(Get-MailboxStatistics -Identity $UserPrincipalName).LastInteractionTime -lt ((Get-Date).AddDays(-$Days))
    $LogonInactive = $(Get-MailboxStatistics -Identity $UserPrincipalName).LastLogonTime -lt ((Get-Date).AddDays(-$Days))
    if ($InteractionInactive -or $LogonInactive) { $Active = $false } else { $Active = $true }

    # Set blocked and mailbox statistics
    $Blocked = (Get-MsolUser -UserPrincipalName $UserPrincipalName).BlockCredential
    $Statistics = Get-Mailbox -Identity $UserPrincipalName | Get-MailboxStatistics

    # Get users licenses
    $Licenses = $(Get-MsolUser -UserPrincipalName $UserPrincipalName).Licenses
    $AssignedLicenses = $Licenses | foreach-Object {$_.AccountSkuId}

    # Create printable string
    $LicenseString = ''
    foreach ($License in $AssignedLicenses) {
            if ($License -eq 'reseller-account:EXCHANGESTANDARD') { $LicenseString = "Exchange Online (Plan 1) $LicenseString" }
            if ($License -eq 'reseller-account:O365_BUSINESS_ESSENTIALS') { $LicenseString = "Microsoft 365 Business Basic $LicenseString" }
            if ($License -eq 'reseller-account:O365_BUSINESS') { $LicenseString = "Microsoft 365 Apps for Business $LicenseString" }
            if ($License -eq 'reseller-account:ENTERPRISEPACK') { $LicenseString = "Office 365 E3 $LicenseString" }
    }

    # Write to file
    if ((-not $Active) -and (-not $($LicenseString -eq ''))) {
        Write-Host "Writing user to file: $($User.DisplayName), $UserPrincipalName, $($Statistics.LastInteractionTime)"
        Add-Content -Path $FilePath -Value "$($User.DisplayName),$UserPrincipalName,$($Statistics.LastInteractionTime),$($Statistics.LastLogonTime),$Blocked,$LicenseString,$Active"
    }

}

# Mail variables
$MailFrom = "MAIL_FROM"
$MailTo = "MAIL_TO"

$SmtpServer = "outlook.office365.com"
$SmtpPort = 587

$Subject = "SUBJECT_TEXT"
$Body = "BODY_TEXT"

# Send email
Send-MailMessage -From $MailFrom -to $MailTo -Subject $Subject `
-Body $Body -SmtpServer $SmtpServer -port $SmtpPort `
-Credential $Login -UseSsl -Attachment $FilePath
