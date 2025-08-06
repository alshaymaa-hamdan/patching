#!/bin/bash
region="us-east-1"
source wait_for_status.sh
 
# update without reboot
 
patch_command_id=$(aws ssm send-command --targets "Key=instanceIds,Values=" --document-name "AWS-InstallWindowsUpdates" --comment "Install Windows updates without reboot" --parameters '{"Operation":["Install"],"RebootOption":["NoReboot"]} --region $region')
 
# Call the function from the source file
waitforstatus Success $region $patch_command_id
