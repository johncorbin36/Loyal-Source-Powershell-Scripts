# Parameters for script
param([String]$FilePath="C:\temp\Empty-Distribution-Lists.csv")

# Connect to script dependencies 
Connect-ExchangeOnline

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath  -Value '"List Name"'

# Get each user in distribution group
$i = 0
foreach ($Group in $Groups = Get-DistributionGroup -ResultSize Unlimited) {

    # Write progress
    $i++
    Write-Progress -Activity "Checking group: $($Group.DisplayName)" -Status "$(($i / $Groups.Count)* 100)% Complete:" -PercentComplete (($i / $Groups.Count)* 100)

    # Get members
    $GroupName = $Group.DisplayName
    $Members = Get-DistributionGroupMember -Identity $GroupName

    # If number of members is 0 or null
    Write-Host "Checking distribution list: $GroupName"
    if ($Members.Count -eq 0) { Add-Content -Path $FilePath -Value "$GroupName" }

}

# Complete
Write-Host "Script complete."
Write-Host "Data exported to $($FilePath)"
