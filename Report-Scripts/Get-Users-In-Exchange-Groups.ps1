# Parameters for script
param([String]$FilePath="C:\temp\Users-In-Exchange-Groups.csv")

# Connect to script dependencies 
Connect-ExchangeOnline

# Create CSV for data
if (Test-Path $FilePath) { Remove-Item $FilePath }
Add-Content -Path $FilePath -Value '"Group Name","Name","Email","Permissions"'

# For each shared mailbox
$i = 0
foreach ($Group in $Groups = Get-Group -ResultSize Unlimited) {
    
    # Write progress
    $i++
    Write-Progress -Activity "Writing group to list: $($Group.DisplayName)" -Status "$(($i / $Groups.Count)* 100)% Complete:" -PercentComplete (($i / $Groups.Count)* 100)

    # Set data for security group
    if ($Group.RecipientTypeDetails -eq 'RoleGroup') {
        
        # Gather group members for loop
        $j = 0
        foreach ($Member in $Members = Get-RoleGroupMember $Group.Name) {

            # Write progress
            $j++
            Write-Progress -Activity "Writing user to list: $($Member.DisplayName)" -Status "$(($i / $Members.Count)* 100)% Complete:" -PercentComplete (($i / $Members.Count)* 100)

            # Write to list
            Add-Content -Path $FilePath -Value "$($Group.Name -Replace ',',''),$($Member.DisplayName),$($Member.PrimarySmtpAddress),$($)"

        }

    }

    # Set data for distribution list
    elseif ($Group.RecipientTypeDetails -eq 'MailUniversalDistributionGroup') {

        # Gather members for loop 
        $j = 0
        foreach ($Member in $Members = Get-DistributionGroupMember -Identity $Group.DisplayName) {

            # Write progress
            $j++
            Write-Progress -Activity "Writing user to list: $($Member.DisplayName)" -Status "$(($i / $Members.Count)* 100)% Complete:" -PercentComplete (($i / $Members.Count)* 100)

            # Write to list
            Add-Content -Path $FilePath -Value "$($Group.DisplayName -Replace ',',''),$($Member.DisplayName),$($Member.PrimarySmtpAddress)"

        }

    }

    # Set data for unified group
    elseif ($Group.RecipientTypeDetails -eq 'GroupMailbox') {

        # Write progress 
        $j = 0
        foreach ($Member in $Members = Get-UnifiedGroupLinks -Identity $Group.DisplayName -LinkType Members) {

            # Write progress
            $j++
            Write-Progress -Activity "Writing user to list: $($Member.DisplayName)" -Status "$(($i / $Members.Count)* 100)% Complete:" -PercentComplete (($i / $Members.Count)* 100)

            # Write to list
            Add-Content -Path $FilePath -Value "$($Group.DisplayName -Replace ',',''),$($Member.DisplayName),$($Member.PrimarySmtpAddress)"

        }

    }

    # Add space in between exchange group records
    Add-Content -Path $FilePath -Value " "

}

# Complete
Write-Host "Script complete."
Write-Host "Data exported to $($FilePath)"
