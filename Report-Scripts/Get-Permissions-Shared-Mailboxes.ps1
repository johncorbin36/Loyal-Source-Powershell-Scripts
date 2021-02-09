# Parameters for script
param([String]$FilePath="C:\temp\Get-Shared-Mailbox-Permissions.csv")

# Connect to script dependencies 
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) { Install-Module -Name ExchangeOnlineManagement }
Connect-ExchangeOnline

# Add header to CSV export file
Add-Content -Path $FilePath -Value "Mailbox Name, Permission Name, Permission User, Permission Access Rights"

# Iterate through shared mailboxes 
foreach ($Mailbox in Get-Mailbox -RecipientTypeDetails SharedMailbox) {

    # Iterate through each permission on a mailbox
    foreach ($Permission in Get-MailboxPermission -Identity $Mailbox.Identity | Select-Object Identity, User, AccessRights) {
        
        # Write to console 
        Write-Host "$($Mailbox.DisplayName),$($Permission.Identity),$($Permission.User),$($Permission.AccessRights)"

        # Filter self permissions 
        if ($Permission.User -ne 'NT AUTHORITY\SELF') {
            Add-Content -Path $FilePath -Value "$($Mailbox.DisplayName),$($Permission.Identity),$($Permission.User),$($Permission.AccessRights)"
        }
    
    }

    # Add a spacer in the export file
    Add-Content -Path $FilePath -Value " "

}
