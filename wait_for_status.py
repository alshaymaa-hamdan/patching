import boto3
import sys
import time
 
def wait_for_ssm_command(command_id, region):
   
    ssm = boto3.client("ssm", region_name=region)
 
    print(f"[INFO] Waiting for SSM command {command_id} to complete...")
 
    status = "InProgress"
    while status in ["InProgress", "Pending"]:
        resp = ssm.list_command_invocations(
            CommandId=command_id,
            Details=True
        )
 
        if not resp["CommandInvocations"]:
            print("[ERROR] No command invocation found")
            sys.exit(1)
 
        status = resp["CommandInvocations"][0]["Status"]
        print(f"[INFO] Current status: {status}")
 
        if status in ["InProgress", "Pending"]:
            time.sleep(15)
 
    print(f"[INFO] Final status: {status}")
 
    if status != "Success":
        print(f"[ERROR] The command failed with status: {status}")
        sys.exit(1)
 
    # Print command output
    outputs = []
    for invocation in resp["CommandInvocations"]:
        for plugin in invocation.get("CommandPlugins", []):
            outputs.append(plugin.get("Output", ""))
 
    if outputs:
        print("\n".join(outputs))
