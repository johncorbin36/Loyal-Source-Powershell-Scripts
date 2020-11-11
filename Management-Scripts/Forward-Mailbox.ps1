# Parameters for script
param([String]$MailboxAddress='', [String]$ForwardingAddress='')

# Connect to script dependencies 
Connect-ExchangeOnline

# Get variables if not defined
if ($MailboxAddress -eq '') { $MailboxAddress = Read-Host "Please enter the mailbox address" }
if ($ForwardingAddress -eq '') { $ForwardingAddress = Read-Host "Please enter the forwarding address" }

# Forward mailbox
Set-Mailbox -Identity $MailboxAddress -ForwardingAddress $ForwardingAddress
Write-Host "Forwarded ${MailboxAddress} to ${ForwardingAddress}."

# Complete
Write-Host "Script complete."
