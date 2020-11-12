# Parameters for script
param([String]$FilePath="C:\temp\All-Exchange-Groups.csv")

# Connect to script dependencies 
Connect-ExchangeOnline

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Group Name","Email","Number of Members","Group Type"'

# For each shared mailbox
$i = 0
foreach ($Group in $Groups = Get-Group -ResultSize Unlimited) {
    
    # Write progress
    $i++
    Write-Progress -Activity "Writing group to list: $($Group.DisplayName)" -Status "$(($i / $Groups.Count)* 100)% Complete:" -PercentComplete (($i / $Groups.Count)* 100)

    # Get all members of the group 
    if ($Group.RecipientTypeDetails -eq 'MailUniversalDistributionGroup'){ $Members = Get-DistributionGroupMember -Identity $Group.DisplayName } 
    else { $Members = "N/A" }

    # Write data to file
    Add-Content -Path $FilePath -Value "$($Group.DisplayName),$($Group.WindowsEmailAddress),$($Members.Count),$($Group.RecipientTypeDetails)"

}

# Complete
Write-Host 'Script complete.'
Write-Host "Data exported to $($FilePath)"
