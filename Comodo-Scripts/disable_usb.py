import subprocess

command = subprocess.run('powershell.exe Set-ItemProperty -Path "HKLM:/SYSTEM/CurrentControlSet/Services/usbstor" -Name "Start" -Value 4')
