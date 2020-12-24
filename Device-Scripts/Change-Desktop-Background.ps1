
# Set lockscreen values
New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows" -Name Personalization -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name LockScreenImage -value "PATH"
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\CurrentVersion\Policies" -Name System -Force

# Set background values
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name Wallpaper -value "PATH"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name WallpaperStyle -value "4"

# Update user profile
Start-Sleep -s 10
rundll32.exe user32.dll, UpdatePerUserSystemParameters, 0, $false

# Disable background change
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop\" -Name NoChangingWallPaper -Value "1"
