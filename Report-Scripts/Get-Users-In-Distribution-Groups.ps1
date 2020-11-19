# Parameters for script
param([Int32]$Days=30, [String]$FilePath="C:\temp\Users-In-Distribution-Groups.csv")

# Connect to script dependencies 
Connect-ExchangeOnline

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Group Name","Name","Email","Status"'

# For each shared mailbox
$i = 0
foreach ($Group in $Groups = Get-DistributionGroup -ResultSize Unlimited) {
    
        # Write progress
        $i++
        Write-Progress -Activity "Writing group to list: $($Group.DisplayName)" -Status "$(($i / $Groups.Count)* 100)% Complete:" -PercentComplete (($i / $Groups.Count)* 100)

        # Gather members for loop 
        foreach ($Member in Get-DistributionGroupMember -Identity $Group.DisplayName) {

            # Check if user is inactive
            if ($(Get-MailboxStatistics -Identity $Member.DisplayName).LastLogonTime -lt ((Get-Date).AddDays(-$Days))) {

                # Write to list
                Write-Host "Writing inactive user $($Member.DisplayName) to list." -ForegroundColor Red
                Add-Content -Path $FilePath -Value "$($Group.DisplayName -Replace ',',''),$($Member.DisplayName),$($Member.UserPrincipalName),Inactive"

            } else {

                # Write to list
                Write-Host "Writing active user $($Member.DisplayName) to list." -ForegroundColor Green
                Add-Content -Path $FilePath -Value "$($Group.DisplayName -Replace ',',''),$($Member.DisplayName),$($Member.UserPrincipalName),Active"

            }

        }

    # Add space in between exchange group records
    Add-Content -Path $FilePath -Value " "

}

# Complete
Write-Host "Script complete."
Write-Host "Data exported to $($FilePath)"
