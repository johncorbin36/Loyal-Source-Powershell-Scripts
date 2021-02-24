import json
import platform

# Try statement to handle errors
try:

    # Open config json
    with open('C:/ProgramData/OpenDNS/ERC/config.json') as f:
        config_data = json.load(f)

    # Open organization info json
    with open('C:/ProgramData/OpenDNS/ERC/OrgInfo.json') as f:
        org_data = json.load(f)

    # Get device name
    device_name = platform.node()

    # Print cisco device information
    print(device_name + ", " + config_data["deviceId"] + ", " + org_data["organizationId"] + ", " + org_data["userId"])

# Catch error
except:
    print("Failed to gather Cisco Umbrella information.")
