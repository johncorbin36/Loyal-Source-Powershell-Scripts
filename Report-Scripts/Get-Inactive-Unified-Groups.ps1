# Parameters for script
param([Int32]$Days=365, [String]$FilePath="C:\temp\Inactive-Unified-Groups.csv")

# Connect to script dependencies 
Connect-ExchangeOnline
Connect-AzureAD

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Unified Group Name","Unified Group Email","Last Activity Date","Total Members"'

# For each unified group in AzureAd 
$i = 0
foreach ($Group in $Groups = Get-UnifiedGroup -ResultSize Unlimited) {

    # Write progress
    $i++
    Write-Progress -Activity "Checking group: $($Group.DisplayName)" -Status "$(($i / $Groups.Count)* 100)% Complete:" -PercentComplete (($i / $Groups.Count)* 100)

    # Get mailbox statistics
    $Statistics = Get-MailboxFolderStatistics -Identity $Group.PrimarySmtpAddress -IncludeOldestAndNewestItems -FolderScope ConversationHistory

    # Check if inactive
    if (($Statistics.NewestItemReceivedDate -lt $(Get-Date).AddDays(-$Days)) -and ($Statistics.NewestItemReceivedDate -ne $Null)) {
        Write-Host "$($Group.PrimarySmtpAddress) has been inactive for over $Days days." -ForegroundColor Red
        $Users = Get-UnifiedGroupLinks -Identity $Group.PrimarySmtpAddress -LinkType Members
        Add-Content -Path $FilePath -Value "$($Group.DisplayName),$($Group.PrimarySmtpAddress),$($Statistics.NewestItemReceivedDate),$($Users.Count)"
    }

}

# Complete
Write-Host 'Script complete.'
Write-Host "Data exported to $($FilePath)"
