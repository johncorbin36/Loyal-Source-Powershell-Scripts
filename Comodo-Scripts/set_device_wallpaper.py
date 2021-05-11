import subprocess
import ctypes
import os

# Download wallpaper
subprocess.Popen(['powershell.exe Invoke-WebRequest "https://i.ibb.co/K5zrr5z/Loyal-Source-Black.png" -OutFile "C:\Windows\Web\Wallpaper\LoyalSource.png"'])

# Change wallpaper (using Python 2)
wallpaper_directory = "C:/Windows/Web/Wallpaper/LoyalSource.png"
ctypes.windll.user32.SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, wallpaper_directory, SPIF_SENDCHANGE)

# Disable wallpaper modification
os.system('cmd /c "REG ADD HKCU/Microsoft/Windows/CurrentVersion/Policies/ActiveDesktop /v NoChangingWallPaper /t REG_SZ /d 1 /f"')
os.system('cmd /c "REG ADD HKLM/Microsoft/Windows/CurrentVersion/Policies/ActiveDesktop /v NoChangingWallPaper /t REG_SZ /d 1 /f"')

# Enable wallpaper modification
# os.system('cmd /c "REG DELETE HKCU/Microsoft/Windows/CurrentVersion/Policies/ActiveDesktop /v NoChangingWallPaper /f"')
# os.system('cmd /c "REG DELETE HKLM/Microsoft/Windows/CurrentVersion/Policies/ActiveDesktop /v NoChangingWallPaper /f"')
