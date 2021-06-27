Connect-AzureAD

# Change address/location information for all AzureAD users in tenant

# Set variables
$Street = "ENTER ADDRESS"
$Zip = "ENTER ZIP"
$State = "ENTER STATE"
$City = "ENTER CITY"
$Office = "ENTER OFFICE NAME"
$Usage = "ENTER TWO LETTER COUNTRY CODE"
$Country = "ENTER COUNTRY"
$Company = "ENTER COMPANY"

# Gather all users
$Users = Get-AzureADUser -All $true

# Update info for each user
foreach ($User in $Users) {

    # Update individual user
    Set-AzureADUser -ObjectID $User.ObjectId -StreetAddress $Street -PostalCode $Zip -State $State -City $City -PhysicalDeliveryOfficeName $Office -CompanyName $Company -UsageLocation $Usage -Country $Country

    # Write to console
    Write-Host "Record updated for $($User.DisplayName)"

}
