#!/bin/bash
 
region="us-west-2"
 
stop_command_id=$(aws ssm send-command --targets "Key=instanceIds,Values=$instances_ids" --document-name "AWS-RunPowerShellScript" --comment "Stopping Qlik services" --parameters '{"commands":["$services=@(\"Spooler\",\"W32Time\");foreach($svc in $services){try{$s=Get-Service -Name $svc -ErrorAction Stop;if($s.Status -ne \"Stopped\"){Stop-Service -Name $svc -Force -ErrorAction Stop;Write-Host \"Stopped $($s.DisplayName)\"}else{Write-Host \"$($s.DisplayName) already stopped\"}}catch{Write-Host \"Error with $svc: $_\"}}"]}' --region "$region")
 
# Call the function from the source file
# waitforstatus Success $region $stop_command_id
 
echo "Command ID: $stop_command_id"
