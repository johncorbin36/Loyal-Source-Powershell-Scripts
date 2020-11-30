# Connect to script dependencies 
Connect-ExchangeOnline
Connect-AzureAD

# Variables for menu
$Option = "Y"
$Data = @()

# Import all users
Write-Host "Adding users from text file."
foreach($line in Get-Content C:\term_list.txt) {
        if($line -match $regex){
            $Data = $Data + $line
        }
}

# For each user (priority)
$i = 0
foreach($Entry in $Data) {

        # Write progress
        $i++
        Write-Progress -Activity "Blocking signin for: $Entry" -Status "$(($i / $Data.Count)* 100)% Complete:" -PercentComplete (($i / $Data.Count)* 100)

        # Set email
        $UserEmail = $Entry

        # Get AzureAD profile requirements 
        $UserID = (Get-AzureADUser -SearchString $UserEmail).ObjectID

        # Block user sign-in
        Set-AzureADUser -ObjectID $UserEmail -AccountEnabled $false
        Write-Host "Blocked ${UserEmail} sign-in." -ForegroundColor Green

        # Initiate sign out of all devices
        Revoke-AzureADUserAllRefreshToken -ObjectId $UserID
        Write-Host "Successfully signed ${UserEmail} out of all devices." -ForegroundColor Green

}

# For each user (non priority)
$i = 0
foreach($Entry in $Data) {

        # Write progress
        $i++
        Write-Progress -Activity "Cleaning user account: $Entry" -Status "$(($i / $Data.Count)* 100)% Complete:" -PercentComplete (($i / $Data.Count)* 100)

        # Set email
        $UserEmail = $Entry

        # Get AzureAD profile requirements 
        $UserID = (Get-AzureADUser -SearchString $UserEmail).ObjectID

        # Convert to shared mailbox
        Set-Mailbox -Identity $UserEmail
        Write-Host "Shared mailbox." -ForegroundColor Green

        # Disable Activesync and OWA for devices
        Set-CASMailbox -Identity $UserEmail -OWAEnabled $false -ActiveSyncEnabled $false
        Write-Host "Disabled OWA and ActiveSync." -ForegroundColor Green

        # Reset Microsoft 365 Password
        Set-AzureADUserPassword -ObjectId $UserID -Password $(ConvertTo-SecureString "PASSWORD_HERE" -asplaintext -force)
        Write-Host "Changed user password."

        # Remove user from all distribution groups
        foreach($DistributionGroup in Get-DistributionGroup | Where-Object { (Get-DistributionGroupMember $_ | ForEach-Object {$_.WindowsLiveID}) -Contains $UserEmail }) {
                Write-Host "Removing user from ${Holder}" -ForegroundColor Green
                Remove-DistributionGroupMember $DistributionGroup -Member $UserEmail -Confirm:$false
        }

        # Remove users from all Azure groups
        foreach($AzureGroup in Get-AzureADUserMembership -All $true -ObjectID $UserEmail) {
                Write-Host "Removing user from ${Holder}" -ForegroundColor Green
                Remove-AzureADGroupMember -ObjectID $AzureGroup.ObjectID -MemberId $(Get-AzureADUser -ObjectID $UserEmail).ObjectID
        }

        # Remove user from all shared email boxes
        foreach ($Mailbox in Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | Get-MailboxPermission -User $UserEmail) {
                Write-Host "Removing user from $($Mailbox.Alias)" -ForegroundColor Green
                Remove-MailboxPermission -Identity $Mailbox.Alias -User $UserEmail -AccessRights FullAccess -InheritanceType All -Confirm:$false
        }

        # Iteration complete
        Write-Host "Terminated user $UserEmail successfully." -ForegroundColor Green
        Write-Host ""

}

# Script complete
Write-Host "Terminated all users."
Write-Host "Script complete."
