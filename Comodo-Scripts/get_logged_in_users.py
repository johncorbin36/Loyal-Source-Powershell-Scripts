import socket, os

# Get hostname
hostname = socket.gethostname()

# Get all logged in users
print(os.system('cmd /c "query user /server:' + hostname + '"'))
