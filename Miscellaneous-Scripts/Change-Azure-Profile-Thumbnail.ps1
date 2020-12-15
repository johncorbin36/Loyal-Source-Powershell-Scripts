
# For each Azure profile
foreach ( $User in $AzureUsers = Get-AzureADUser -All $True ) {

    # Set profile photo
    Set-AzureADUserThumbnailPhoto -ObjectId $User.ObjectId -FilePath "C:\Image-Location.jpg"

}
