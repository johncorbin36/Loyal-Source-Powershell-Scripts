param([String]$FilePath="C:\temp\Guest-Users.csv")

# Login to script dependencies
Connect-MsolService 
Connect-AzureAD 

# Remove residual file and create new one
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Name","Email","License"'

# Iterate through each user in Azure DB
foreach($User in Get-AzureADUser -All $true) {

    # Check if user is a guest
    if ($User.UserType -eq 'Guest') {

        # Get users licenses
        $Licenses = $(Get-MsolUser -UserPrincipalName $User.UserPrincipalName).Licenses
        $AssignedLicenses = $Licenses | foreach-Object {$_.AccountSkuId}

        # Create printable string
        $LicenseString = ''
        foreach ($License in $AssignedLicenses) {
                if ($License -eq 'reseller-account:EXCHANGESTANDARD') { $LicenseString = "Exchange Online (Plan 1) $LicenseString" }
                if ($License -eq 'reseller-account:O365_BUSINESS_ESSENTIALS') { $LicenseString = "Microsoft 365 Business Basic $LicenseString" }
                if ($License -eq 'reseller-account:O365_BUSINESS') { $LicenseString = "Microsoft 365 Apps for Business $LicenseString" }
                if ($License -eq 'reseller-account:ENTERPRISEPACK') { $LicenseString = "Office 365 E3 $LicenseString" }
        }
        
        # Write users to file
        Write-Host "$($User.DisplayName), $($User.userPrincipalName), $LicenseString"
        Add-Content -Path $FilePath -Value "$($User.DisplayName),$($User.UserPrincipalName), $LicenseString"

    }

}
