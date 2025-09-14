#!/bin/bash
 
region="us-west-2"
instances_ids=$1
start_command_id=$(aws ssm send-command --targets "Key=instanceIds,Values=$instances_ids" --document-name "AWS-RunPowerShellScript" --comment "Starting Qlik services" --parameters '{"commands":["$services=@(\"Spooler\",\"W32Time\");foreach($svc in $services){try{$s=Get-Service -Name $svc -ErrorAction Stop;if($s.Status -ne \"Running\"){Start-Service -Name $svc -ErrorAction Stop;Write-Host (\"Started \" + $s.DisplayName);Start-Sleep -Seconds 5}else{Write-Host ($s.DisplayName + \" already running\")}}catch{Write-Host (\"Error with \" + $svc + \": \" + $_)}}"]}' --region "$region")
 
# Call the function from the source file
# waitforstatus Success $region $stop_command_id
 
echo "Command ID: $start_command_id"
