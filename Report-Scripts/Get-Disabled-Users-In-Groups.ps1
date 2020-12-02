# Set params
param([String]$FilePath="C:\temp\Disabled-Users-In-Groups.csv", [Bool]$InternalOnly=$true)

# Login to script dependencies
Connect-MsolService 
Connect-AzureAD 

# Remove residual file and create new one
if (Test-Path $FilePath) { Remove-Item $FilePath }

# Iterate through each azure group
$i = 0
foreach ($Group in $Groups = Get-AzureADGroup -All $true) {

    # Write progress
    $i++
    Write-Progress -Activity "Checking user: $($Group.DisplayName)" -PercentComplete (($i / $Groups.Count)* 100)

    # Iterate through each user in group
    foreach ($Member in Get-AzureADGroupMember -ObjectId $Group.ObjectId -All $true) {

        # Check if user account is enabled
        if ((Get-MsolUser -UserPrincipalName $Member.UserPrincipalName).BlockCredential) {
            Add-Content -Path $FilePath -Value "$($Group.DisplayName -replace ',', ''), $($Member.UserPrincipalName)"
        }

    }

}
