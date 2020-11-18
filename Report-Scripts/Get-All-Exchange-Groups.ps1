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

    # Set data for security group
    if ($Group.RecipientTypeDetails -eq 'RoleGroup') {
        $Members = Get-RoleGroupMember $Group.Name
        Add-Content -Path $FilePath -Value "$($Group.Name -Replace ',',''),Not Applicable,$($Members.Count),$($Group.RecipientTypeDetails)"
    }

    # Set data for distribution list
    elseif ($Group.RecipientTypeDetails -eq 'MailUniversalDistributionGroup') {
        $Members = Get-DistributionGroupMember -Identity $Group.DisplayName
        Add-Content -Path $FilePath -Value "$($Group.DisplayName -Replace ',',''),$($Group.WindowsEmailAddress),$($Members.Count),$($Group.RecipientTypeDetails)"
    }

    # Set data for unified group
    elseif ($Group.RecipientTypeDetails -eq 'GroupMailbox') {
        $Members = Get-UnifiedGroupLinks -Identity $Group.DisplayName -LinkType Members
        Add-Content -Path $FilePath -Value "$($Group.DisplayName -Replace ',',''),$($Group.WindowsEmailAddress),$($Members.Count),$($Group.RecipientTypeDetails)"
    }

}

# Complete
Write-Host "Script complete."
Write-Host "Data exported to $($FilePath)"
