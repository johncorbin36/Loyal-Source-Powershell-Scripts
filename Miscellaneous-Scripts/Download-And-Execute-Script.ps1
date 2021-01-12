# Download PS script provided the given URL
$url = "DIRECT_DOWNLOAD_URL"
Invoke-WebRequest $url -OutFile "PATH_TO_FILE"

# Change directory
cd "DIRECTORY"

# Change execution policy
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Run script
.\Script-Name.ps1

# Delete script path
Remove-Item -Path "PATH_TO_FILE"
