#!/bin/bash
 
region="us-west-2"
 
stop_command_id=$(aws ssm send-command --targets "Key=instanceIds, Values=$instances_ids" --document-name "AWS-RunPowerShellScript" --comment "Stopping Qlik services" --parameters '{"commands":["$services=@("Spooler","Fax"); foreach ($svc in $services) { try { $svcObj=Get-Service -Name $svc -ErrorAction Stop; if ($svcObj.Status -ne "Stopped") { Stop-Service -Name $svc -Force -ErrorAction Stop; Write-Host "Stopped $svc" } else { Write-Host "$svc already stopped" } } catch { Write-Host "Failed to stop $svc: $_" } }"]}' --region $region)
 
# Call the function from the source file
# waitforstatus Success $region $stop_command_id
 
echo "Command ID: $stop_command_id"
