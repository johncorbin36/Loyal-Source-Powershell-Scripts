# Import winreg (Python 2)
from _winreg import *

# Connect to local machine registry
Registry = ConnectRegistry(None, HKEY_LOCAL_MACHINE)

# Try statement to catch error
try:
	
	# Define key in registry we will be searching
	RawKey = OpenKey(Registry, "SOFTWARE\\WOW6432Node\\Nuance\\Shared\\Products\\AS09\\1.0")
	
	# Iterate through values
	i = 0
	stop = True
	while stop:
		name, value, type = EnumValue(RawKey, i)
		if name == "SerialNumber":
			print(value)
			stop = False
		i += 1
		
# Except statement for error
except:
	
	# Error message 
	print("Failed to gather key.")
