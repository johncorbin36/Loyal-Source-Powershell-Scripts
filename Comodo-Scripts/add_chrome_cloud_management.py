import os

# Enrollment key
key = "ENTER_KEY_HERE"

# Add key to registry
os.system('cmd /c "REG ADD HKLM\SOFTWARE\Policies\Google\Chrome /v CloudManagementEnrollmentToken /t REG_SZ /d ' + key + ' /f"')

# Remove key from registry
# os.system('cmd /c "REG DELETE HKLM\SOFTWARE\Policies\Google\Chrome /v CloudManagementEnrollmentTokenTest /f"')
