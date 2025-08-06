#!/bin/bash
region="us-west-2"
source wait_for_status.sh
instance_ids=$1
 
# update without reboot
 
patch_command_id=$(aws ssm send-command --targets "Key=instanceIds,Values=$instance_ids" --document-name "AWS-InstallWindowsUpdates" --comment "Install Windows updates without reboot" --parameters '{"Action":["Install"],"AllowReboot":["True"]}' --region $region | jq -r '.Command.CommandId')


#i-069eb22f4a5273497,i-035f2c3dc689f04fc

sleep 3
ssmstatus=$(/usr/local/bin/aws ssm list-command-invocations --command-id $patch_command_id --details --query "CommandInvocations[*].StatusDetails[]" --output text)
sleep 3
 
echo "Command ID $patch_command_id is initiated"
echo "Current command status: $ssmstatus "
 
 
if [ "$ssmstatus" == "Failed" ];
then
doutput=$(/usr/local/bin/aws ssm list-command-invocations --command-id $patch_command_id --details --query "CommandInvocations[].CommandPlugins[*].[Output]" --output text)
printf "\nCommand ID $patch_command_id has finished with following status: $ssmstatus\n"
printf "\nDestination output:----------------------------------------------\n"
printf "\n$doutput\n"
printf "\nEnd of output----------------------------------------------------\n"
exit -1
elif [ "$ssmstatus" == "InProgress" ];
then
 
waitforstatus Success $region $patch_command_id 
fi

doutput=$(/usr/local/bin/aws ssm list-command-invocations --command-id $patch_command_id --details --query "CommandInvocations[].CommandPlugins[*].[Output]" --output text)

ssmstatus=$(/usr/local/bin/aws ssm list-command-invocations --command-id $patch_command_id --details --query "CommandInvocations[*].StatusDetails[]" --output text)
 
printf "\nCommand ID $patch_command_id has finished with $ssmstatus\n"
printf "\nDestination output:----------------------------------------------\n"
printf "\n$doutput\n"
printf "\nEnd of output----------------------------------------------------\n"
