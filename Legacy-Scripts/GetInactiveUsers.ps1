# Check if modules need to be installed
if (-Not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) { Install-Module -Name ExchangeOnlineManagement } 

# Set credentials
$UserLogin = 'EMAIL_LOGIN'
$PasswordLogin = 'PASSWORD_LOGIN'
$PasswordSecure = ConvertTo-SecureString -String $PasswordLogin -AsPlainText -Force
$Login = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserLogin, $PasswordSecure

# Login to script dependencies 
Connect-ExchangeOnline -Credential $Login

# Get all inactive users (2 weeks inactive)
Write-Host "Gathering inactive users. This might take a while."
$InactiveUsers = Get-Mailbox -Resultsize Unlimited | Get-MailboxStatistics | where {$_.LastLogonTime -lt ((Get-Date).AddDays(-14))} | Select DisplayName, LastLogonTime

# Create CSV to export data to
if (Test-Path "C:\temp\InactiveUsers.csv") { Remove-Item "C:\temp\InactiveUsers.csv" }
$FilePath = "C:\temp\InactiveUsers.csv"
Add-Content -Path $FilePath  -Value '"Name","Email","Last Log-On Date"'

# For each inactive user
foreach ($User in $InactiveUsers) {

    # Get user email 
    $Email = Get-User -Identity $User.DisplayName
    Write-Host "User exceeded login threshold:" $Email.UserPrincipalName

    # Export to file
    $Value = "{0},{1},{2}" -f $User.DisplayName,$Email.UserPrincipalName,$User.LastLogonTime
    Add-Content -Path $FilePath -Value $Value

}

# Complete
Write-Host "Script complete."
