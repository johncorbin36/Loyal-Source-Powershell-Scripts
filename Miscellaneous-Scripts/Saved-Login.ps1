
# Set credentials
$UserLogin = 'USER_LOGIN_EMAIL'
$PasswordLogin = 'USER_LOGIN_PASSWORD'
$PasswordSecure = ConvertTo-SecureString -String $PasswordLogin -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserLogin, $PasswordSecure

# Login to script dependencies with saved credentials
Connect-ExchangeOnline -Credential $Login
Connect-MsolService -Credential $Login
Connect-AzureAD -Credential $Login

# Gather permissions from Azure app
New-PartnerAccessToken -ApplicationId 'APPLICATION_TOKEN' -Scopes 'https://api.partnercenter.microsoft.com/user_impersonation' -ServicePrincipal -Credential $Credential -Tenant 'TENANT-ID' -UseAuthorizationCode
