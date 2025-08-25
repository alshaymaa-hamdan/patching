import os
import boto3
import json
from wait_for_status import wait_for_ssm_command
 

# Jenkins will provide these as environment variables
instance_ids = os.getenv("InstanceID")  # e.g. "i-0387b2fe22897d04a,i-0581419c27f336162"
region = "us-west-2"
instance_ids_list = [i.strip() for i in instance_id.split(",") if i.strip()]

if not instance_ids:
    raise ValueError("Missing required environment variable: instance_ids")

client = boto3.client("ssm", region_name=region)

# PowerShell script to start Qlik services
ps_script = r'''
$services=@("Spooler","W32Time");
foreach($svc in $services){
    try {
        $s = Get-Service -Name $svc -ErrorAction Stop
        if ($s.Status -ne "Stopped") {
            Stop-Service -Name $svc -ErrorAction Stop
            Write-Host ("Stopped " + $s.DisplayName)
            Start-Sleep -Seconds 15
        } else {
            Write-Host ($s.DisplayName + " already stopped")
        }
    } catch {
        Write-Host ("Error with " + $svc + ": " + $_)
    }
}
'''

response = client.send_command(
    Targets=[{"Key": "instanceIds", "Values": instance_ids_list}],
    DocumentName="AWS-RunPowerShellScript",
    Comment="Starting Qlik services",
    Parameters={"commands": [ps_script]}
)

command_id = response["Command"]["CommandId"]
print(f"Command ID: {command_id}")
wait_for_ssm_command(command_id,region)
