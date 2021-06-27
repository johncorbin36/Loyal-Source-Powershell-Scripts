import subprocess

# Change Legal Notice Caption
command = subprocess.Popen('powershell.exe Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value "ENTER TEXT HERE"')

# Change Legal Notice Text
command = subprocess.Popen('powershell.exe Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value "ENTER TEXT HERE"')