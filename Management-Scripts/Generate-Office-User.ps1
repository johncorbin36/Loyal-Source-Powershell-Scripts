# Parameters for script
param([String]$FilePath="C:\temp\Generate-Office-User.csv")

# Login to azure and exchange as dependencies 
Connect-AzureAD

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath  -Value '"Name","Email","Password","Laptop Pin"'

# Variables for menu
$Option = "Y"
$Data = @()

# Menu info 
Write-Host "Enter all user accounts you wish to create."
Write-Host "Enter data in the following convention: 'John Doe'"
Write-Host "If the user has two last names please seperate with a hyphen."
Write-Host "--------------------------------------------------------------"

# Menu to add users to termination que
while ($True) {

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
        $UserPrincipalName = $MailNickName + "@loyalsource.com"

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

    # Create new AzureAD user
    New-AzureADUser -DisplayName $Entry -GivenName $FirstName -SurName $LastName -UserPrincipalName $UserPrincipalName -MailNickName $MailNickName -PasswordProfile $PasswordProfile -AccountEnabled $true 
    
    # Output all data for account
    Write-Host "Generated user account for $Entry." -ForegroundColor Green
    Add-Content -Path $FilePath -Value "$Entry,$UserPrincipalName,$Password,$LaptopPin"

}

# Complete
Write-Host 'Script complete.'
Write-Host "Data exported to $($FilePath)"
