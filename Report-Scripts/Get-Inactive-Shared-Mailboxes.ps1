# Parameters for script
param([Int32]$Days=365, [String]$FilePath="C:\temp\Inactive-Shared-Mailboxes.csv")

# Connect to script dependencies 
Connect-ExchangeOnline

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Mailbox Name","Mailbox Email","Last Activity"'

# Set date variables
$StartDate = $(Get-Date).AddDays(-$Days)

# For all shared mailboxes
foreach ($Mailbox in Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited) {

    # Get mailbox statistics
    $Statistics = Get-MailboxStatistics -Identity $Mailbox.PrimarySmtpAddress

    # Check if inactive
    if ($Statistics.LastInteractionTime -lt $StartDate) {
        Write-Host "$($Mailbox.PrimarySmtpAddress) has been inactive for over a year." -ForegroundColor Red
        Add-Content -Path $FilePath -Value "$($Mailbox.Alias),$($Mailbox.PrimarySmtpAddress),$($Statistics.LastInteractionTime)"
    }
    
}

# Complete
Write-Host "Script complete."
Write-Host "Data exported to $($FilePath)"
