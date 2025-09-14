#!/bin/bash
set -e
 
command_id=$1
region=$2
 
if [ -z "$command_id" ] || [ -z "$region" ]; then
  echo "Usage: $0 <command-id> <region>"
  exit 1
fi
 
echo "[INFO] Waiting for SSM command $command_id to complete..."
 
status="InProgress"
while [ "$status" == "InProgress" ] || [ "$status" == "Pending" ]; do
    status=$(/usr/local/bin/aws ssm list-command-invocations --command-id "$command_id" --details --region "$region" --query "CommandInvocations[0].Status" --output text)
    echo "[INFO] Current status: $status"
    sleep 15
done
 
echo "[INFO] Final status: $status"
 
if [ "$status" != "Success" ]; then
  echo "[ERROR] The command failed with status: $status"
  exit 1
fi
