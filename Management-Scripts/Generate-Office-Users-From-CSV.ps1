# Parameters for script
param([String]$FilePath="C:\temp\Generate-Office-Users.csv")

# Login to azure and exchange as dependencies 
if (-not (Get-Module -ListAvailable -Name AzureAD)) { Install-Module -Name AzureAD }
Connect-AzureAD 
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) { Install-Module -Name ExchangeOnlineManagement }
Connect-ExchangeOnline

# Create CSV to export data
if (-not (Test-Path $FilePath)) {
    New-Item $FilePath -Type File 
    Add-Content -Path $FilePath  -Value '"Name","Email","Password","Laptop Pin","Bullhorn Username"'
}

# Get location of file to load users into the program
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter = "CSV files (*.csv)|*.csv"
}
$null = $FileBrowser.ShowDialog()

# Gather all UPN from AzureAD
Write-Host "Gathering all users from AzureAD."
$AzureUPN = @()
$ADUsers = Get-AzureADUser -All $True | Select-Object 'UserPrincipalName'
foreach ($User in $ADUsers) { $AzureUPN = $AzureUPN + $User.UserPrincipalName }

# For each user in data 
$i = 0
$UserEmails = @()
foreach($Name in $Data = Import-CSV $FileBrowser.FileName | Select-Object -ExpandProperty 'Name') {

    # Write progress
    $i++
    Write-Progress -Activity "Generating User: $Name" -Status "$(($i / $Data.Count)* 100)% Complete:" -PercentComplete (($i / $Data.Count)* 100)

    # Sets the display name, first name, and last name for new account
    $FirstName = $Name.split(' ')[0]
    $LastName = $Name.split(' ')[1]

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
        $UserPrincipalName = $MailNickName + "DOMAIN.COM"

        # Check if user email exists in Azure
        if ($AzureUPN -Contains $UserPrincipalName) { Write-Host "Email already exists in database" -ForegroundColor Red }
        else { Write-Host "Email does not exist in database." -ForegroundColor Green; break}

        # Next iteration 
        $i = $i + 1

    }

    # Generate random password
    $Password = ''
    for ($i = 0; $i -lt 5; $i++) { $Password += 'abcdefghkmnprstuvwxyzABCDEFGHKMNPRSTUVWXYZ'[(Get-Random (0..41))]}
    for ($i = 0; $i -lt 2; $i++) { $Password += '123456789'[(Get-Random (0..8))]}
    for ($i = 0; $i -lt 1; $i++) { $Password += '!#$%&*+?'[(Get-Random (0..7))]}
    $Password = ($Password -Split '' | Sort-Object {Get-Random}) -Join ''

    # Set password
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $Password

    # Generate laptop pin
    $LaptopPin = Get-Random (100000..1000000)

    # Generate bullhorn username convention
    $Bullhorn = $UserPrincipalName -split '@'
    $Bullhorn = $Bullhorn[0] + ".loy"

    # Create new AzureAD user
    New-AzureADUser -DisplayName $Name -GivenName $FirstName -SurName $LastName -UserPrincipalName $UserPrincipalName -MailNickName $MailNickName -PasswordProfile $PasswordProfile -AccountEnabled $true 
    
    # Add user to distribution group array
    $UserEmails = $UserEmails + $UserPrincipalName

    # Output all data for account
    Write-Host "Generated user account for $Name." -ForegroundColor Green
    Add-Content -Path $FilePath -Value "$Name,$UserPrincipalName,$Password,$LaptopPin,$Bullhorn"

}

# Wait for users to be added to groups
Write-Host "Accounts created. Program resuming in ten minutes to finish user setup." 
Start-Sleep -s 600

# Loop for each user 
foreach ($UserEmail in $UserEmails) {

    # Adding users terminal output
    Write-Host "Finishing up user account for: ${UserEmail}" 

    # Get user object id
    $AzureUser = Get-AzureADUser -SearchString $UserEmail

    # Get data from csv
    $UserData = Import-CSV $FileBrowser.FileName | Where-Object Name -eq $AzureUser.DisplayName

    # Add use to global dristro groups / security groups
    Add-DistributionGroupMember -Identity "GROUP_IDENTITY" -Member $UserEmail # LSGS All
    Add-DistributionGroupMember -Identity "GROUP_IDENTITY" -Member $UserEmail # Enterprise 
    Add-AzureADGroupMember -ObjectId "GROUP_IDENTITY" -RefObjectId $AzureUser.ObjectId # MDM Security

    # Fill in user data on Azure
    if ($UserData.PersonalEmail -ne '') { Set-AzureADUser -ObjectId $User.ObjectId -OtherMails $UserData.PersonalEmail }
    if ($UserData.Phone -ne '') { Set-AzureADUser -ObjectId $User.ObjectId -TelephoneNumber $UserData.Phone }
    if ($UserData.Department -ne '') { Set-AzureADUser -ObjectId $User.ObjectId -Department $UserData.Department }
    if ($UserData.StreetAddress -ne '') { Set-AzureADUser -ObjectId $User.ObjectId -StreetAddress $UserData.StreetAddress }
    if ($UserData.City -ne '') { Set-AzureADUser -ObjectId $User.ObjectId -City $UserData.City }
    if ($UserData.PostalCode -ne '') { Set-AzureADUser -ObjectId $User.ObjectId -PostalCode $UserData.PostalCode }
    if ($UserData.State -ne '') { Set-AzureADUser -ObjectId $User.ObjectId -State $UserData.State }

    # Update users manager
    if ($UserData.Manager -ne '') {
        Write-Host "MANAGER CODE"
        #Set-AzureADUserManager -ObjectId $User.ObjectId -State $UserData.State
    }

    # Set title for user account
    if ($UserData.Title -ne '') {
        Set-AzureADUser -ObjectId $User.ObjectId -JobTitle $UserData.Title
    
        # Switch statement to add employee to specific azure groups
        switch($UserData.Title) {

            "Temp Contract Recruiter" {
                Add-DistributionGroupMember -Identity "GROUP_IDENTITY" -Member $UserEmail # Bullhorn Staffing
            } 
            "Government Healthcare Recruiter" {
                Add-DistributionGroupMember -Identity "GROUP_IDENTITY" -Member $UserEmail # Bullhorn Staffing
            } 
            "Travel Healthcare Recruiter" {
                Add-DistributionGroupMember -Identity "GROUP_IDENTITY" -Member $UserEmail # Bullhorn Staffing
            } 
            "Credentialing Specialist" {
                Add-DistributionGroupMember -Identity "GROUP_IDENTITY" -Member $UserEmail # Bullhorn Staffing
            }

        }

    }

    # Create distribution group and assign user to it
    if ($UserData.Title -contains '') {
        Write-Host "CREATE DISTRO CODE"
    }

}

# Complete
Write-Host 'Script complete.'
Write-Host "Data exported to $($FilePath)"
