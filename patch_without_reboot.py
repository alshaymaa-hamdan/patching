import boto3
import os
 
# Read environment variables
instance_ids = os.getenv("InstanceID")  # expects comma-separated list
region = "us-west-2"
instance_ids_list = [i.strip() for i in instance_id.split(",") if i.strip()]

# Create SSM client
ssm = boto3.client("ssm", region_name=region)
 
# Send command
response = ssm.send_command(
    Targets=[{"Key": "instanceIds", "Values": instance_ids_list}],
    DocumentName="AWS-InstallWindowsUpdates",
    Comment="Install Windows updates without reboot",
    Parameters={
        "Action": ["Install"],
        "AllowReboot": ["False"]
    }
)
 
# Extract command ID
command_id = response["Command"]["CommandId"]
print(f"Command ID: {command_id}")
