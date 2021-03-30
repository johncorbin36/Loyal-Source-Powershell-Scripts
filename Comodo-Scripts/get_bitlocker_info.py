from subprocess import check_output

out = check_output('powershell.exe Write-Host $(Get-BitlockerVolume -MountPoint C: | Select-Object -ExpandProperty KeyProtector).RecoveryPassword')
recovery_password = out.decode("utf-8")
recovery_password = recovery_password.replace(" ", "")

out = check_output('powershell.exe Write-Host $(Get-BitlockerVolume -MountPoint C: | Select-Object -ExpandProperty KeyProtector).KeyProtectorId')
key_protector_id = out.decode("utf-8")
key_protector_id = key_protector_id.replace("{", "")
key_protector_id = key_protector_id.replace("}", "")
key_protector_id = key_protector_id.replace("\n", "")
key_protector_id = key_protector_id.split(" ")
key_protector_id = key_protector_id[1]

print(key_protector_id + ", " + recovery_password)
