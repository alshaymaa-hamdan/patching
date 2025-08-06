waitforstatus () {
    target_status=$1
    target_region=$2
    sh_command_id=$3
    ssmstatus="InProgress"
    while [ "$ssmstatus" != "$target_status" ]; do
        ssmstatus=$(/usr/local/bin/aws ssm list-command-invocations --command-id $sh_command_id --details --query "CommandInvocations[*].StatusDetails[]" --output text)*
        sleep 5
        printf "Waiting for command to finish\n"
 
        if [ $ssmstatus == "Failed" ];
        then
        doutput=$(/usr/local/bin/aws ssm list-command-invocations --command-id $sh_command_id --details --query "CommandInvocations[].CommandPlugins[*].[Output]" --output text)*
        printf "\nCommand ID $sh_command_id has finished with following status: $ssmstatus\n"
        printf "\nDestination output:----------------------------------------------\n"
        printf "\n$doutput\n"
        printf "\nEnd of output----------------------------------------------------\n"
        exit -1
        elif [ "$ssmstatus" == "Cancelled" ];
        then
        doutput=$(/usr/local/bin/aws ssm list-command-invocations --command-id $sh_command_id --details --query "CommandInvocations[].CommandPlugins[*].[Output]" --output text)*
        printf "\nCommand ID $sh_command_id has finished with following status: $ssmstatus\n"
        printf "\nDestination output:----------------------------------------------\n"
        printf "\n$doutput\n"
        printf "\nEnd of output----------------------------------------------------\n"
        exit -1
        elif [ "$ssmstatus" == "DeliveryTimedOut" ];
        then
        doutput=$(/usr/local/bin/aws ssm list-command-invocations --command-id $sh_command_id --details --query "CommandInvocations[].CommandPlugins[*].[Output]" --output text)
        printf "\nCommand ID $sh_command_id has finished with following status: $ssmstatus\n"
        printf "\nDestination output:----------------------------------------------\n"
        printf "\n$doutput\n"
        printf "\nEnd of output----------------------------------------------------\n"
        exit -1
        fi
            done
}
