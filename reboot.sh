#!/bin/bash
 
region="us-west-2"
# source shared_jobs/wait_for_status.sh
 
reboot_command_id=$(aws ssm send-command --targets "Key=instanceIds,Values=$instances_ids" --document-name "AWS-RunPowerShellScript" --comment "Check for reboot and reboot if required after patching" --parameters 'commands=["$rebootPending = Test-Path \"HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired\"","if ($rebootPending) { Restart-Computer -Force }"]' --region $region)
 
# Call the function from the source file
# waitforstatus Success $region $reboot_command_id
echo "Command ID: $reboot_command_id"
