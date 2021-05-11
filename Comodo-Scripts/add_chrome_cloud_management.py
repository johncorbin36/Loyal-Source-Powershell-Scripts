import os, shutil

# Add or remove
add = False

# Enrollment key
key = 'ENTER_KEY_HERE'

# Add cloud management to device
if add:

    try:

        # Add cloud management to device
        os.system('cmd /c "REG ADD HKLM\SOFTWARE\Policies\Google\Chrome /v CloudManagementEnrollmentToken /t REG_SZ /d ' + key + ' /f"')

        print('Added successfully.')
    
    else:

        print('Failed to add successfully.')

# Remove cloud management from device
else:

    try:

        # Remove current user registry keys
        os.system('cmd /c "REG DELETE HKCU\Software\Google\Chrome /f"')
        os.system('cmd /c "REG DELETE HKCU\Software\Policies\Google\Chrome /f"')

        # Remove local machine registry keys
        os.system('cmd /c "REG DELETE HKLM\Software\Google\Chrome /f"')
        os.system('cmd /c "REG DELETE HKLM\Software\Policies\Google\Chrome /f"')
        os.system('cmd /c "REG DELETE HKLM\Software\Policies\Google\Update /f"')
        os.system('cmd /c "REG DELETE HKLM\Software\WOW6432Node\Google\Enrollment /f"')
        os.system('cmd /c "REG DELETE HKLM\Software\WOW6432Node\Google\Update\ClientState\{430FD4D0-B729-4F61-AA34-91526481799D} /v CloudManagementEnrollmentToken /f"')

        # Remove policy directory
        shutil.rmtree('C:/Program Files (x86)/Google/Policies')

        print('Removed successfully.')

    except:

        print('Failed to remove successfully.')
