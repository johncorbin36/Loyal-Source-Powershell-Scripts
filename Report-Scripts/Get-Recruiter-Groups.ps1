# Parameters for script
param([String]$FilePath="C:\temp\All-Recruiter-Groups.csv")

# Connect to script dependencies 
Connect-ExchangeOnline

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Group Name","Email","Number of Members"'

# For each shared mailbox
$i = 0
foreach ($Group in $Groups = Get-Group -ResultSize Unlimited) {

    # Write progress
    $i++
    Write-Progress -Activity "Checking group: $($Group.DisplayName)" -Status "$(($i / $Groups.Count)* 100)% Complete:" -PercentComplete (($i / $Groups.Count)* 100)

    # Check if group is for recruiters 
    if ($($Group.DisplayName -Split '')[2] -eq '.') {
        Write-Host $Group.DisplayName "is a recruiter group." -ForegroundColor Magenta
        $Members = Get-DistributionGroupMember -Identity $Group.DisplayName
        Add-Content -Path $FilePath -Value "$($Group.DisplayName),$($Group.WindowsEmailAddress),$($Members.Count)"
    }

}

# Complete
Write-Host "Script complete."
Write-Host "Data exported to $($FilePath)"
