# Parameters for script
param([String]$FilePath="C:\temp\Get-Blocked-Credential-By-Email.csv", [String]$EmailList="Email-List.txt")

# Connect to dependencies 
if (-not (Get-Module -ListAvailable -Name AzureAD)) { Install-Module -Name AzureAD }
Connect-AzureAD 
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) { Install-Module -Name ExchangeOnlineManagement }
Connect-ExchangeOnline

# Iterate through email list
foreach($line in Get-Content .\$EmailList) {

    # Read line
    if($line -match $regex){

        # Check if credential is blocked 
        if ((Get-MsolUser -SearchString $line).BlockCredential) { Add-Content -Path $FilePath -Value '$line' }

    }

}
