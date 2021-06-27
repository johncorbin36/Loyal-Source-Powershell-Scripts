param([String]$FilePath="C:\temp\Generate-User-Accounts.csv")
Connect-AzureAD 

while ($True) {

    # Gather name of employee
    $line = Read-Host "Please enter employee name"

    # Set license
    $planName = "EXCHANGESTANDARD"
    $License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
    $License.SkuId = (Get-AzureADSubscribedSku | Where-Object -Property SkuPartNumber -Value $planName -EQ).SkuID
    $LicensesToAssign = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
    $LicensesToAssign.AddLicenses = $License

    # Generate random password
    $Password = ""
    for ($i = 0; $i -lt 3; $i++) { $Password += "abcdefghkmnprstuvwxyz"[(Get-Random (0..20))]}
    for ($i = 0; $i -lt 2; $i++) { $Password += "ABCDEFGHKMNPRSTUVWXYZ"[(Get-Random (0..20))]}
    for ($i = 0; $i -lt 2; $i++) { $Password += "123456789"[(Get-Random (0..8))]}
    for ($i = 0; $i -lt 1; $i++) { $Password += '$!?'[(Get-Random (0..2))]}

    # Set password and disable change on next login
    $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
    $PasswordProfile.Password = $Password
    $PasswordProfile.ForceChangePasswordNextLogin = $False

    # Setup Azure User
    Set-AzureADUser -ObjectId $line -UsageLocation "US" -PasswordProfile $PasswordProfile
    Set-AzureADUserLicense -ObjectId $line -AssignedLicenses $LicensesToAssign

    # Write to console
    Write-Host "User account created for $($line) `n"

    # Write to file
    Add-Content -Path $FilePath -Value "$line, $Password"

}
