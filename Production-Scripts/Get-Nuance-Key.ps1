# Registry values
$RegLocation = "HKLM:\SOFTWARE\WOW6432Node\Nuance\Shared\Products\AS09\1.0"
$RegKey = "SerialNumber"

# Check is path exists
$ValueExists = (Get-Item "HKLM:\SOFTWARE\WOW6432Node\Nuance\Shared\Products\AS09\1.0" -EA Ignore).Property -contains "SerialNumber"

# Get value
$SerialNumber = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Nuance\Shared\Products\AS09\1.0").SerialNumber

### One liner 
# if ((Get-Item "HKLM:\SOFTWARE\WOW6432Node\Nuance\Shared\Products\AS09\1.0" -EA Ignore).Property -contains "SerialNumber") { (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Nuance\Shared\Products\AS09\1.0").SerialNumber }