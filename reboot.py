import boto3
import os
 
# Read environment variables
instance_ids = os.getenv("InstanceID")  # expects comma-separated list
region = "us-east-1"
 
# Create SSM client
ssm = boto3.client("ssm", region_name=region)
 
# PowerShell commands for reboot check
commands = [
    r'$rebootPending = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"',
    r'if ($rebootPending) { Restart-Computer -Force }'
]
 
# Send command
response = ssm.send_command(
    Targets=[{"Key": "instanceIds", "Values": instance_ids.split(",")}],
    DocumentName="AWS-RunPowerShellScript",
    Comment="Check for reboot and reboot if required after patching",
    Parameters={"commands": commands}
)
 
# Extract command ID
command_id = response["Command"]["CommandId"]
print(f"Command ID: {command_id}")
