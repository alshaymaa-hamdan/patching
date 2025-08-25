import boto3
import sys
import time

def wait_for_ssm_command(command_id, region, instance_ids=None, timeout=3600):
    ssm = boto3.client("ssm", region_name=region)

    print(f"[INFO] Waiting for SSM command {command_id} to complete on {instance_ids}", flush=True)

    start_time = time.time()
    statuses = {iid: "InProgress" for iid in instance_ids}

    while any(s in ["InProgress", "Pending"] for s in statuses.values()):
        resp = ssm.list_command_invocations(
            CommandId=command_id,
            InstanceId=instance_ids[0] if len(instance_ids) == 1 else None,
            Details=True
        )

        for invocation in resp["CommandInvocations"]:
            iid = invocation["InstanceId"]
            statuses[iid] = invocation["Status"]
            print(f"[INFO] Instance {iid} status: {statuses[iid]}", flush=True)

        # Timeout safeguard
        if time.time() - start_time > timeout:
            raise TimeoutError(f"Command {command_id} did not finish within {timeout} seconds")

        time.sleep(15)

    print(f"[INFO] Final statuses: {statuses}")

    # Fail if any instance failed
    for iid, st in statuses.items():
        if st != "Success":
            print(f"[ERROR] Instance {iid} failed with status: {st}", flush=True)
            sys.exit(1)
