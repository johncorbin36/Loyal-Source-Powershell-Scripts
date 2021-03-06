from subprocess import check_output

# Gather the model name
model = check_output("powershell.exe Write-Host $(Get-CimInstance Win32_DiskDrive | Select-Object Model).Model")
model = str(model)
model = model.replace("\\n'", "")
model = model.replace("b'", "")

# Gather the serial
serial = check_output("powershell.exe Write-Host $(Get-CimInstance Win32_DiskDrive | Select-Object SerialNumber).SerialNumber")
serial = str(serial)
serial = serial.replace(".\\n'", "")
serial = serial.replace("b'", "")
print(serial)
