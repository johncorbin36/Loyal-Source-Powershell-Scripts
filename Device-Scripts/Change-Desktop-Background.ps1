
# Change registry location of wallpaper and update system params
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d c:\Image-Location.jpg /f
Start-Sleep -s 10
rundll32.exe user32.dll, UpdatePerUserSystemParameters, 0, $false
