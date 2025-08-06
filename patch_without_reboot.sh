#!/bin/bash
region="us-west-2"

instance_ids=$1

# update without reboot
 
patch_command_id=$(aws ssm send-command --targets "Key=instanceIds,Values=$instance_ids" --document-name "AWS-InstallWindowsUpdates" --comment "Install Windows updates without reboot" --parameters '{"Action":["Install"],"AllowReboot":["True"]}' --region $region | jq -r '.Command.CommandId')

#i-069eb22f4a5273497,i-035f2c3dc689f04fc

echo "Command ID: $patch_command_id"
