# Check if modules need to be installed
if (-Not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) { Install-Module -Name ExchangeOnlineManagement } 
if (-Not (Get-Module -ListAvailable -Name MSOnline)) { Install-Module -Name MSOnline } 
