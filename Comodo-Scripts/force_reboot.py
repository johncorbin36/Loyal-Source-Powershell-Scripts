import subprocess
from subprocess import check_output

# Set number of days
days = 7

# Get days from boot time
out = check_output('powershell.exe $((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).days')

# Compare to limit
if int(out) >= days:

    # Run restart command
    subprocess.Popen('powershell.exe Restart-Computer -Force')
    print("Machine restarted.")
