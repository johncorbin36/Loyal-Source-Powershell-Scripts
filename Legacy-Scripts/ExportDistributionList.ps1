# Check if modules need to be installed
if (-Not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) { Install-Module -Name ExchangeOnlineManagement } 

# Login to microsoft dependencies
Connect-ExchangeOnline

# Force generate file path if it does not exist
New-Item -ItemType Directory -Force -Path "Names/"

# Loop through each distribution group and create text files containing data
$DistributionGroups = Get-DistributionGroup
Write-Host $DistributionGroups.count
$i = 0
foreach ($db in $DistributionGroups) {

    # Get all users in db list to variable 
    $DistributionName = $db.DisplayName
    Write-Host "Getting all users from ${DistributionName}"
    $Users = Get-DistributionGroupMember -Identity $db.PrimarySmtpAddress
    $UserCount = $Users.count
    Write-Host "User total is ${UserCount}"

    # Filters users and writes name to array
    '' | Add-Content "Names/${DistributionName}.txt"
    foreach ($User in $Users) { $User.DisplayName | Add-Content "Names/${DistributionName}.txt" }

    # Tracking variables 
    $i = $i + 1
    Write-Host $i
    Write-Host $i $db.DisplayName

}

# Define directory and create array of files
$Directory = Get-Location
$Files = Get-ChildItem -Path "$Directory\Names\" -Filter *.txt

# Set header and content 
$Header = $Files | foreach {$_.basename}
$Content = $Files | foreach { ,(gc $_.fullname) }

# Write lines for each column
$Lines = for($i=0; $i -lt $Content.Count; $i++)
{
    $Line = for($x=0; $x -lt $Files.count; $x++)
    {
        $Content[$x][$i]
    }
    $Line -join ','
}

# Export csv
$Lines | ConvertFrom-Csv -Header $Header | Export-Csv names.csv
