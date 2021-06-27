param([String]$FilePath="C:\temp\EmployeeNumberUpdate.csv")

Connect-AzureAD

foreach ($User in Get-AzureADUser -All $true) {

    $Ext = Get-AzureADUserExtension -ObjectId $User.ObjectId
    
    # Write to file
    Add-Content -Path $FilePath -Value "$($User.ObjectId), $($User.DisplayName), $($Ext.employeeId)"

}
