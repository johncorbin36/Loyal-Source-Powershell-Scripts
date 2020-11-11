# Parameters for script
param([String]$MailboxAddress='')

# Connect to script dependencies 
Connect-ExchangeOnline

# Get mailbox address if not defined
if ($MailboxAddress -eq '') { $MailboxAddress = Read-Host "Please enter the mailbox address you wish to unforward" }

# Unforwarded mailbox
Set-Mailbox -Identity $MailboxAddress -ForwardingAddress $null
Write-Host "Unforwarded ${MailboxAddress}."

# Complete
Write-Host "Script complete."
