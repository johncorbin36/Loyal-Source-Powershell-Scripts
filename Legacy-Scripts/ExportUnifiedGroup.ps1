# Check if modules need to be installed
if (-Not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) { Install-Module -Name ExchangeOnlineManagement } 

# Login to microsoft dependencies
Connect-ExchangeOnline

# Force generate file path if it does not exist
New-Item -ItemType Directory -Force -Path "Names/"

# Loop through each office group and create text files containing data
$UnifiedGroups = Get-UnifiedGroup
Write-Host $UnifiedGroups.count
$i = 0
foreach ($ug in $UnifiedGroups) {

    # Get all users in ug list to variable 
    $UnifiedName = $ug.DisplayName
    if ($UnifiedName.Contains("/")) { $UnifiedName = $UnifiedName.replace("/", "-") }
    Write-Host "Getting all users from ${UnifiedName}"
    $Users = Get-UnifiedGroupLinks -Identity $ug.PrimarySmtpAddress -LinkType Members
    $UserCount = $Users.count
    Write-Host "User total is ${UserCount}"

    # Filters users and writes name to array
    '' | Add-Content "Names/${UnifiedName}.txt"
    foreach ($User in $Users) { 
        $WriteLine = $User.DisplayName
        if ($WriteLine.Contains(",")) { $WriteLine = $WriteLine.replace(",", "") }
        $WriteLine | Add-Content "Names/${UnifiedName}.txt" 
    }

    # Tracking variables 
    $i = $i + 1
    Write-Host $i
    Write-Host $i $ug.DisplayName

}

# Define directory and create array of files
$Directory = Get-Location
$Files = Get-ChildItem -Path "$Directory\Names\" -Filter *.txt

# Set header and content 
$Header = $Files|foreach {$_.basename}
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
$Lines | ConvertFrom-Csv -Header $Header | Export-Csv UnifiedGroup_User_Names.csv
