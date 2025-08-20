import boto3
import subprocess
import sys
import time
import os
from shared_jobs.wait_for_status import wait_for_ssm_command
 
# Read environment variables (like your Bash script uses $InstanceID and $region)
instance_id = os.getenv("InstanceID")
region = os.getenv("region")



# Create SSM client
ssm = boto3.client("ssm", region_name=region)
 
# Send command
response = ssm.send_command(
    DocumentName="AWS-RunPatchBaseline",
    InstanceIds=[instance_id],
    Parameters={
        "Operation": ["Install"],
        "RebootOption": ["RebootIfNeeded"]
    },
    TimeoutSeconds=600
)
 
command_id = response["Command"]["CommandId"]
 
# Wait 3 seconds
time.sleep(3)
 
# Print command ID
print(command_id)
 
# Call the wait for status function
wait_for_ssm_command(command_id, region)
