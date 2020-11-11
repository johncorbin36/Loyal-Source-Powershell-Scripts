# Parameters for script
param([String]$FilePath="C:\temp\Empty-Azure-Groups.csv")

# Connect to script dependencies 
Connect-AzureAD

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Group Name","Email"'

# Get all groups in Azure Directory
$Groups = Get-AzureADGroup -All $True

# For each group in Azure Directory
$i = 0
foreach ($Group in $Groups) {
    
    # Write progress
    $i++
    Write-Progress -Activity "Checking group: $($Group.DisplayName)" -Status "$(($i / $Groups.Count)* 100)% Complete:" -PercentComplete (($i / $Groups.Count)* 100)

    # Get all members of the group 
    $Members = Get-AzureADGroupMember -ObjectId $Group.ObjectId -All $True

    # Check if the group is empty and write to list if true
    if ($Members.Count -eq 0) {

        # Write group to file
        Write-Host $Group.DisplayName " is empty." -ForegroundColor DarkYellow
        Add-Content -Path $FilePath -Value "$($Group.DisplayName),$($Group.Mail)"

    }

}

# Complete
Write-Host 'Script complete.'
Write-Host "Data exported to $($FilePath)"
