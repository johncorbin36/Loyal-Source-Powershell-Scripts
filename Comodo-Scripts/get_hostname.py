import platform, socket

# Checks if host name is different 
if platform.node() != socket.gethostname():
    print(platform.node() + " " + socket.gethostname())
else: 
    print(socket.gethostname())
