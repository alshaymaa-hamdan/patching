#!/bin/bash
InstanceID=$1
sh_command_id=$(/usr/local/bin/aws ssm send-command --document-name "AWS-RunPatchBaseline" --instance-ids "$InstanceID"  --parameters '{"Operation":["Install"],"RebootOption":["RebootIfNeeded"]}' --timeout-seconds 600 --region $region --query "Command.CommandId" --output text)
sleep 3
echo "$sh_command_id"
./wait_for_status.sh $sh_command_id $region
