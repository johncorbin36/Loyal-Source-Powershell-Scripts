# Connect to script dependencies 
Connect-ExchangeOnline
Connect-AzureAD

# Variables for menu
$Option = "Y"
$Data = @()

# Menu to add user data for termination 
Write-Host "Enter all user accounts you wish to enable."
while ($true) {

        # Add user to enable
        if (($Option -eq "Y") -or ($Option -eq "y")) {
                $Term_Email = Read-Host "Enter email of account to enable"
                $Data = $Data + $Term_Email
        } elseif (($Option -eq "N") -or ($Option -eq "n")) {
                break
        } else {
                Write-Host "Input not understood, please try again."
        }

        # Get option for menu
        $Option = Read-Host "Do you want to enter another account? [Y] for yes [N] for no"

}

# For each user (priority)
$i = 0
foreach($Entry in $Data) {

        # Write progress
        $i++
        Write-Progress -Activity "Blocking signin for: $($Entry.Split(":")[0])" -Status "$(($i / $Data.Count)* 100)% Complete:" -PercentComplete (($i / $Data.Count)* 100)

        # Set emails
        $Emails = $Entry.Split(":")
        $UserEmail = $Emails[0]

        # Get AzureAD profile requirements 
        $UserID = (Get-AzureADUser -SearchString $UserEmail).ObjectID

        # Block user sign-in
        Set-AzureADUser -ObjectID $UserEmail -AccountEnabled $true
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
        Write-Progress -Activity "Cleaning user account: $($Entry.Split(":")[0])" -Status "$(($i / $Data.Count)* 100)% Complete:" -PercentComplete (($i / $Data.Count)* 100)

        # Set emails
        $Emails = $Entry.Split(":")
        $UserEmail = $Emails[0]
        $ManagerEmail = $Emails[1]

        # Get AzureAD profile requirements 
        $UserID = (Get-AzureADUser -SearchString $UserEmail).ObjectID

        # Mailbox
        if ($ManagerEmail -ne '') {

                # Convert to shared mailbox and forward to manager
                Set-Mailbox -Identity $UserEmail -DeliverToMailboxAndForward $false -ForwardingSMTPAddress $ManagerEmail
                Get-Mailbox -Identity $UserEmail | Add-MailboxPermission -User $ManagerEmail -AccessRights fullaccess -InheritanceType all
                Write-Host "Added manager to terminated users mailbox and forwarded inbox to manager. " -ForegroundColor Green

        } else {

                # Convert to shared mailbox
                Set-Mailbox -Identity $UserEmail -Type Shared
                Write-Host "Shared mailbox." -ForegroundColor Green

        }

        # Disable Activesync and OWA for devices
        Set-CASMailbox -Identity $UserEmail -OWAEnabled $false -ActiveSyncEnabled $false
        Write-Host "Disabled OWA and ActiveSync." -ForegroundColor Green

        # Reset Microsoft 365 Password
        Set-AzureADUserPassword -ObjectId $UserID -Password $(ConvertTo-SecureString "PASSWORD_HERE" -asplaintext -force)
        Write-Host "Changed user password."


        # Iteration complete
        Write-Host "Terminated user $UserEmail successfully." -ForegroundColor Green
        Write-Host ""

}

# Script complete
Write-Host "Script complete."
