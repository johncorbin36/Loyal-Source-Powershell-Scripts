# Check if modules need to be installed
if (-Not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) { Install-Module -Name ExchangeOnlineManagement } 

# Login to microsoft dependencies
Connect-ExchangeOnline

# Get all users from distribution list 
$DistributionListIdentity = Read-Host "Please enter distribution list email"
$DistroName = Get-DistributionGroup -Identity $DistributionListIdentity
$Users = Get-DistributionGroupMember -Identity $DistributionListIdentity

# Create CSV for user data
$FilePath = "C:\temp\${DistroName}UserDetails.csv"
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath  -Value '"Name","Email"'

# Filters users and writes name to array
foreach ($User in $Users) {
    $Name = $User.DisplayName
    Write-Host "Writing user ${$Name}"
    $Value = "{0},{1}" -f $Name,$User.WindowsLiveID
    Add-Content -Path $FilePath -Value $Value
}

# Completed
Write-Host "Script complete, data exported to: C:\temp\${DistroName}UserDetails.csv"
