
# Get password
$AccountPassword = Read-Host AsSecureString

# Set account password
$LocalAdmin = Get-LocalUser -Name "USER_NAME"
$LocalAdmin | Set-LocalUser -Password $AccountPassword
