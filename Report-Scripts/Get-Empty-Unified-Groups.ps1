# Parameters for script
param([String]$FilePath="C:\temp\Empty-Unified-Groups.csv")

# Connect to script dependencies 
Connect-AzureAD

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Unified Group Name","Unified Group Email"'

# Get unified groups
$Groups = Get-UnifiedGroup -ResultSize Unlimited

# For each unified group in AzureAd 
$i = 0
foreach ($Group in $Groups) {

    # Write progress
    $i++
    Write-Progress -Activity "Checking group: $($Group.DisplayName)" -Status "$(($i / $Groups.Count)* 100)% Complete:" -PercentComplete (($i / $Groups.Count)* 100)

    # Check if the group is empty and write to list if true
    if ($(Get-UnifiedGroupLinks -Identity $Group.DisplayName -LinkType Members).Count -eq 0) {

            # Write group to file
            Write-Host $Group.DisplayName "is empty." -ForegroundColor DarkYellow
            Add-Content -Path $FilePath -Value "$($Group.DisplayName),$($Group.PrimarySmtpAddress)"

    }

}

# Complete
Write-Host 'Script complete.'
Write-Host "Data exported to $($FilePath)"
