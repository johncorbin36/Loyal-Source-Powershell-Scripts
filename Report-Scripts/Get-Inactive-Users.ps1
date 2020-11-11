# Parameters for script
param([Int32]$Days=14, [String]$FilePath="C:\temp\Inactive-Exchange-Users.csv")

# Connect to script dependencies 
Connect-ExchangeOnline
Connect-MsolService 

# Get all inactive users 
Write-Progress -Activity "Gathering all inactive users."
$InactiveUsers = Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Where-Object {$_.LastLogonTime -lt ((Get-Date).AddDays(-$Days))} | Select-Object DisplayName, LastLogonTime

# Delete CSV for user data and create new CSV
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Name","Email","Last Log-On Date","License"'

# For each inactive user
$i = 0
Write-Host "Writing a total of $($InactiveUsers.Count) inactive users to list."
foreach ($User in $InactiveUsers) {
        
        # Write progress
        $i++
        Write-Progress -Activity "Writing user to list: $($User.DisplayName)" -PercentComplete (($i / $InactiveUsers.Count)* 100)

        # Get users email
        $ExchangeUser = Get-User -Identity $User.DisplayName

        # Get users licenses
        $LicensedUser = Get-MsolUser -UserPrincipalName $ExchangeUser.UserPrincipalName
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

                # Write licensed user details to CSV
                Write-Host "$($User.DisplayName) is licensed." -ForegroundColor DarkRed
                $Value = "{0},{1},{2},{3}" -f $User.DisplayName,$ExchangeUser.UserPrincipalName,$User.LastLogonTime,$LicenseString
                Add-Content -Path $FilePath -Value $Value

        } else {

                # Write non-licensed user details to CSV
                Write-Host "$($User.DisplayName) is not licensed." -ForegroundColor DarkYellow
                $Value = "{0},{1},{2},{3}" -f $User.DisplayName,$ExchangeUser.UserPrincipalName,$User.LastLogonTime,$LicenseString
                Add-Content -Path $FilePath -Value $Value

        }

}

# Complete
Write-Host "Script complete."
Write-Host "Data exported to $($FilePath)"
