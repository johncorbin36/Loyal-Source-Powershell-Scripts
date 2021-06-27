import ctypes, os

# Try statement to catch errors
try:
 	is_admin = os.getuid() == 0
except AttributeError:
 	is_admin = ctypes.windll.shell32.IsUserAnAdmin() != 0

# Print bool to check if admin or not
print(is_admin)