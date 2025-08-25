import boto3
import os
from wait_for_status import wait_for_ssm_command
 
# Read environment variables
instance_ids = os.getenv("InstanceID")  # expects comma-separated list
region = "us-west-2"
instance_ids_list = [i.strip() for i in instance_ids.split(",") if i.strip()]
 
# Create SSM client
ssm = boto3.client("ssm", region_name=region)
 
# PowerShell commands for reboot check
commands = [
    r'$rebootPending = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"',
    r'if ($rebootPending) { Restart-Computer -Force }'
]
 
# Send command
response = ssm.send_command(
    Targets=[{"Key": "instanceIds", "Values": instance_ids_list}],
    DocumentName="AWS-RunPowerShellScript",
    Comment="Check for reboot and reboot if required after patching",
    Parameters={"commands": commands}
)
 
# Extract command ID
command_id = response["Command"]["CommandId"]
print(f"Command ID: {command_id}")
wait_for_ssm_command(command_id,region)
