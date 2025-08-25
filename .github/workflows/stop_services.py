import boto3
import os
 
# Read environment variables
instance_ids = os.getenv("instance_ids")  # expects comma-separated list
region = "us-east-1"
 
# Create SSM client
ssm = boto3.client("ssm", region_name=region)
 
# Send command
response = ssm.send_command(
    Targets=[{"Key": "instanceIds", "Values": instance_ids.split(",")}],
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
