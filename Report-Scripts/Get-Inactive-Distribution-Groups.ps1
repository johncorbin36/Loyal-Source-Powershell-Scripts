# Parameters for script
param([Int32]$Days=10, [String]$FilePath="C:\temp\Inactive-Distribution-Groups.csv")

# Connect to script dependencies 
Connect-ExchangeOnline

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Distrobution Group Name","Distrobution Group Email"'

# Set date variables
$EndDate = Get-Date
$StartDate = $EndDate.AddDays(-$Days)

# Get all distribution groups
$Groups = Get-DistributionGroup -ResultSize Unlimited
foreach ($Group in $Groups) {

    # Get number of emails from set dates
    $RecievedEmails = Get-MessageTrace -SenderAddress $Group.PrimarySmtpAddress -StartDate $StartDate -EndDate $EndDate
    Write-Host "$Group has recieved $($RecievedEmails) in the past $Days days."

    # Check for inactivity 
    if ($RecievedEmails.count -eq 0) {
        Write-Host $Group "is inactive." -ForegroundColor Red
        Add-Content -Path $FilePath -Value "$($Group.DisplayName),$($Group.PrimarySmtpAddress)"
    } else {
        Write-Host $Group "is active." -ForegroundColor Green
    }

}
