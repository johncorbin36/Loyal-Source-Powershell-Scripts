# Parameters for script
param([String]$FilePath="C:\temp\Users-Blocked-Account.csv")

# Connect to script dependencies 
Connect-AzureAD

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Name","Email"'

# For each user in Azure
$i = 0
foreach ($User in $Users = Get-AzureADUser -All $True) {
    
    # Write progress
    $i++
    Write-Progress -Activity "Checking if user is blocked: $($User.DisplayName)" -Status "$(($i / $Users.Count)* 100)% Complete:" -PercentComplete (($i / $Users.Count)* 100)

    # Write user with blocked sign-in to file
    if (-not $User.AccountEnabled) { Add-Content -Path $FilePath -Value "$($User.DisplayName),$($User.UserPrincipalName)" }

}

# Complete
Write-Host "Script complete."
Write-Host "Data exported to $($FilePath)"
