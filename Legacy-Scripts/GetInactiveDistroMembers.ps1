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

# Set date variables
$CurrentDate = Get-Date
$ThresholdDate = $CurrentDate.AddDays(-14)

# Get distribution groups
$Groups = Get-DistributionGroup -ResultSize Unlimited

# Get all users 
$Users = Get-User -ResultSize Unlimited
$InactiveUsers = @()

# Create CSV for user data
$FilePath = "C:\temp\InactiveDistributionUsers.csv"
Add-Content -Path $FilePath  -Value "${GroupName}"
Add-Content -Path $FilePath  -Value '"Distribution Group","Name","Email","Last Log-On Date"'

# Get all inactive users
Write-Host "Checking a total of {1} users for inactivity." -f $Users.count
foreach ($User in $Users) {

        # Set name and identifier
        $Name = $User.DisplayName
        Write-Host "Checking last log on date for user: ${Name}"
        $Identifier = $User.WindowsLiveID

        # Get mailbox stats / last logon time
        $MailboxStats = Get-MailboxStatistics -Identity $Identifier
        $LastLogOnDate = $MailboxStats.LastLogonTime

        # Check if difference in days is greater than user defined threshold
        if ($ThresholdDate -gt $LastLogOnDate) {

                # Add user to inactive users
                $InactiveUsers = $InactiveUsers + $User

        }

}

# Get each user in distribution group
foreach ($Group in $Groups) {

    # Get members
    $GroupName = $Group.DisplayName
    $Members = Get-DistributionGroupMember -Identity $GroupName
    Write-Host $GroupName

    # Get all display names
    $MemberDisplayNames = @()
    foreach ($Member in $Members) {
        $MemberDisplayNames = $MemberDisplayNames + $Member.DisplayName
    }

    # For each inactive user
    foreach ($User in $InactiveUsers) {

        # If user exsists in distribution group
        if ($MemberDisplayNames -contains $User.DisplayName) {
            
            # Get mailbox stats / last logon time
            $MailboxStats = Get-MailboxStatistics -Identity $Identifier
            $LastLogOnDate = $MailboxStats.LastLogonTime

            # Write user to file
            Write-Host "User exceeded login threshold: ${LastLogOnDate}"
            $Value = "{0},{1},{2},{3}" -f $GroupName,$User.DisplayName,$User.UserPrincipalName,$LastLogOnDate
            Add-Content -Path $FilePath -Value $Value

        }

    }

}

# Mail variables
$MailFrom = "EMAIL_FROM"
$MailTo = "EMAIL_TO"

$SmtpServer = "outlook.office365.com"
$SmtpPort = 587

$Subject = "Monthly Report of Distribution Inactive Users"
$Body = "Attached is the monthly inactive users by distribution list report."
$Attachment = $FilePath

# Send email
Send-MailMessage -From $MailFrom -to $MailTo -Subject $Subject `
-Body $Body -SmtpServer $SmtpServer -port $SmtpPort `
-Credential $Login -UseSsl -Attachment $Attachment

# Complete
Write-Host 'Complete'
