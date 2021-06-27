# Connect to Exchange Online
## Use Connect-ExchangeOnline to allow for MFA, Get-Credential does not support without secrets/certs
Connect-ExchangeOnline

# Enter the filter/search name that you wish to purge
## Filter/Compliance search is defined in the compliance center or by using PowerShell
### The name of that filter is used to target the set of emails you wish to purge.
$Name = Read-Host "Please enter the name of the compliance search you wish to purge all emails from"

# Hard delete all emails in the compliance search/filter
New-ComplianceSearchAction -SearchName $Name -Purge -PurgeType HardDelete
