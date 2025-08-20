import boto3
import sys
import time

def wait_for_ssm_command(command_id, region, instance_id=None, timeout=3600):
    ssm = boto3.client("ssm", region_name=region)

    print(f"[INFO] Waiting for SSM command {command_id} to complete...")

    status = "InProgress"
    start_time = time.time()

    while status in ["InProgress", "Pending"]:
        kwargs = {"CommandId": command_id, "Details": True}
        if instance_id:
            kwargs["InstanceId"] = instance_id  # Helps ensure we get results

        resp = ssm.list_command_invocations(**kwargs)

        if not resp["CommandInvocations"]:
            print("[WARN] No command invocation found yet, retrying...")
        else:
            status = resp["CommandInvocations"][0]["Status"]
            print(f"[INFO] Current status: {status}")

        # Exit loop if finished
        if status not in ["InProgress", "Pending"]:
            break

        # Timeout safeguard
        if time.time() - start_time > timeout:
            raise TimeoutError(f"Command {command_id} did not finish within {timeout} seconds")

        time.sleep(15)

    print(f"[INFO] Final status: {status}")

    if status != "Success":
        print(f"[ERROR] The command failed with status: {status}")
        sys.exit(1)

    # Fetch final output
    if resp["CommandInvocations"]:
        outputs = []
        for invocation in resp["CommandInvocations"]:
            for plugin in invocation.get("CommandPlugins", []):
                if "Output" in plugin:
                    outputs.append(plugin["Output"])
        if outputs:
            print("\n".join(outputs))
