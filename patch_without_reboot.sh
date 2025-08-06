#!/bin/bash
region="us-west-2"
source wait_for_status.sh
 
# update without reboot
 
patch_command_id=$(aws ssm send-command --targets "Key=instanceIds,Values=i-069eb22f4a5273497,i-035f2c3dc689f04fc" --document-name "AWS-InstallWindowsUpdates" --comment "Install Windows updates without reboot" --parameters '{"Action":["Install"],"AllowReboot":["False"]}' --region $region)
 
# Call the function from the source file
waitforstatus Success $region $patch_command_id
