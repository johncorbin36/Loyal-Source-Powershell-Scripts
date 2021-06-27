# Parameters for script
param([String]$FilePath="C:\temp\Generate-User-Accounts.csv")

# Install dependencies if they do not exist
if (-not (Get-Module -ListAvailable -Name AzureAD)) { Install-Module -Name AzureAD }
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) { Install-Module -Name ExchangeOnlineManagement }

# Connect to dependencies
Connect-AzureAD 
Connect-ExchangeOnline

# Create CSV for data if it does not exist
if (-Not (Test-Path $FilePath)) { Add-Content -Path $FilePath  -Value '"Name","Email","Password","Laptop Pin","Date"' }

# Variables for menu
$Option = "Y"
$Data = @()

# Title
Write-Host "#####################################################"
Write-Host "#                                                   #"
Write-Host "#               USER GENERATION SCRIPT              #"
Write-Host "#                        V.1.0                       #"
Write-Host "#                                                   #"
Write-Host "#         Loyal Source Government Services          #"
Write-Host "#                                                   #"
Write-Host "#####################################################"
Write-Host " "

# Loop script to avoid typing in credentials multiple times
while($True) {

    # Menu info 
    Write-Host "Enter all user accounts you wish to create."
    Write-Host "Enter data in the following convention: 'John Doe'"
    Write-Host "If the user has two last names please seperate with a hyphen."
    Write-Host "Only name conventions 'FIRST LAST' or 'FIRST LAST-LAST' are supported."
    Write-Host "--------------------------------------------------------------"

    # Menu to add users to termination que
    $Incomplete = $True
    while ($Incomplete) {

            # Add user to terminate list
            if (($Option -eq "Y") -or ($Option -eq "y")) { $Data = $Data + $(Read-Host "Enter the first and last name") }

            # End menu system
            elseif (($Option -eq "N") -or ($Option -eq "n")) { break } 

            # Illegal input
            else { Write-Host "Input not understood, please try again." }

            # State options for menu
            $Option = Read-Host "Do you want to enter another user? [Y] for yes [N] for no"

    }

    # Gather all UPN from AzureAD
    Write-Host "Gathering all users from AzureAD."
    $AzureUPN = @()
    $ADUsers = Get-AzureADUser -All $True | Select-Object 'UserPrincipalName'
    foreach ($User in $ADUsers) { $AzureUPN = $AzureUPN + $User.UserPrincipalName }

    # For each user in data 
    $i = 0
    $UserEmails = @()
    foreach($Entry in $Data) {

        # Write progress
        $i++
        Write-Progress -Activity "Generating User: $Entry" -Status "$(($i / $Data.Count)* 100)% Complete:" -PercentComplete (($i / $Data.Count)* 100)

        # Sets the display name, first name, and last name for new account
        $FirstName = $Entry.split(' ')[0]
        $LastName = $Entry.split(' ')[1]

        # Sets the user principal name (email)
        $i = 1
        while ($True) {

            # Get first letter of first name (increase if user identity already exists in Azure)
            $FirstNameEmail = $FirstName.SubString(0, $i)

            # Remove hyphen from mail nick name if applicable 
            if ($LastName.contains('-')) {
                
                # Edit mail nickname
                $LastNameArray = $LastName.split('-')
                $LastName = $LastNameArray[0].SubString(0, 1) + $LastNameArray[1]

                # Set mail nickname
                $MailNickName = $FirstNameEmail + $LastName
                $MailNickName = $MailNickName.ToLower()

            } else {

                # Set mail nickname
                $MailNickName = $FirstNameEmail + $LastName
                $MailNickName = $MailNickName.ToLower()

            }

            # Set user principal name
            $UserPrincipalName = $MailNickName + "@DOMAIN.COM"

            # Check if user email exists in Azure
            if ($AzureUPN -Contains $UserPrincipalName) { Write-Host "Email already exists in database" -ForegroundColor Red }
            else { Write-Host "Email does not exist in database." -ForegroundColor Green; break}

            # Next iteration 
            $i = $i + 1

        }

        # Generate random password
        $Password = ""
        for ($i = 0; $i -lt 3; $i++) { $Password += "abcdefghkmnprstuvwxyz"[(Get-Random (0..20))]}
        for ($i = 0; $i -lt 2; $i++) { $Password += "ABCDEFGHKMNPRSTUVWXYZ"[(Get-Random (0..20))]}
        for ($i = 0; $i -lt 2; $i++) { $Password += "123456789"[(Get-Random (0..8))]}
        for ($i = 0; $i -lt 1; $i++) { $Password += '$!?'[(Get-Random (0..2))]}

        # Set password and disable change on next login
        $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswordProfile.Password = $Password
        $PasswordProfile.ForceChangePasswordNextLogin = $False

        # Generate laptop pin
        $LaptopPin = Get-Random (100000..1000000)

        # Create new AzureAD user
        New-AzureADUser -DisplayName $Entry -GivenName $FirstName -SurName $LastName -UserPrincipalName $UserPrincipalName -MailNickName $MailNickName -PasswordProfile $PasswordProfile -AccountEnabled $true -UsageLocation "US" 

        # Add user to distribution group array
        $UserEmails = $UserEmails + $UserPrincipalName

        # Output all data for Office account
        Write-Host "Generated Office user account for $Entry." -ForegroundColor Green
        $Date = Get-Date -Format "MM/dd/yyyy"
        Add-Content -Path $FilePath -Value "$Entry,$UserPrincipalName,$Password,$LaptopPin,$Date"

    }

    # Wait for users to be added to Office groups and assigned licenses
    Write-Host "Program resuming in ten minutes." 
    Start-Sleep -s 600

    # Loop for each user 
    foreach ($UserEmail in $UserEmails) {

        # Adding users terminal output
        Write-Host "Adding user ${UserEmail} to lists and groups." 

        # Get user object id
        $ObjectId = $(Get-AzureADUser -SearchString $UserEmail).ObjectId

        # Add use to dristro groups / security groups
        Add-DistributionGroupMember -Identity "ENTER UNIQUE IDENTIFIER HERE" -Member $UserEmail # LSGS All
        Add-DistributionGroupMember -Identity "ENTER UNIQUE IDENTIFIER HERE" -Member $UserEmail # Enterprise
        Add-AzureADGroupMember -ObjectId "ENTER UNIQUE IDENTIFIER HERE" -RefObjectId $ObjectId # MDM Security

        # Assign license to user
        $planName = "ENTERPRISEPACK"
        $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
        $License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
        $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $LicensesToAssign.AddLicenses = $License
        Set-AzureADUserLicense -ObjectId $UserEmail -AssignedLicenses $LicensesToAssign

        # Set default AzureAD contact information variables
        $Street = "ENTER ADDRESS"
        $Zip = "ENTER ZIP"
        $State = "ENTER STATE"
        $City = "ENTER CITY"
        $Office = "ENTER OFFICE NAME"
        $Usage = "ENTER TWO LETTER COUNTRY CODE"
        $Country = "ENTER COUNTRY"
        $Company = "ENTER COMPANY"

        # Set default AzureAD contact information
        Set-AzureADUser -ObjectID $ObjectId -StreetAddress $Street -PostalCode $Zip -State $State -City $City -PhysicalDeliveryOfficeName $Office -CompanyName $Company -UsageLocation $Usage -Country $Country


    }

    # Reset variables
    $Option = "Y"
    $Data = @()

    # Complete
    Write-Host 'Script complete.'
    Write-Host "Data exported to $($FilePath)"

}
