#!/bin/bash
#Scale all buybots to zero to ensure job won't run for ever!
CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"

echo -e "\n\nTurning off all buy bots"
scripts/buybots_scale.sh 1 0
echo -e "${CHECK_MARK} Turning off all buy bots"

#Delete old job if it still exists and ignore not found error
echo -e "\n\nDeleting old reset job"
kubectl --context spannerdemo-europe-01 delete job spannerdemo-reset --ignore-not-found
echo -e "${CHECK_MARK} Deleting old reset job"

#Start Reset tickets job
echo -e "\n\nStarting ticket reset job"
kubectl --context spannerdemo-europe-01 create -f `ls k8sgenerated/*reset*`
echo -e "${CHECK_MARK} Starting ticket reset job"

echo -e "\n\n"
start=$SECONDS
until kubectl --context spannerdemo-europe-01 get jobs | grep -q "spannerdemo-reset         3         3";
do 
  end=$SECONDS
  duration=$(( end - start ))
  echo -ne "\e[0K\rWaiting for job to complete: $duration s"
  sleep 2; 
done
echo -e "\n${CHECK_MARK} Ticket reset job complete!"

#Reset Dashboard and Metrics
echo -e "\n\nReseting metrics and clearing the dashboard"
kubectl --context spannerdemo-europe-01 scale deployment spannerdemo-backend-influxdb --replicas 0
kubectl --context spannerdemo-europe-01 scale deployment spannerdemo-dashboard --replicas 0

kubectl --context spannerdemo-europe-01 scale deployment spannerdemo-backend-influxdb --replicas 1
kubectl --context spannerdemo-europe-01 scale deployment spannerdemo-dashboard --replicas 1
echo -e "${CHECK_MARK} Reseting metrics and clearing the dashboard"
echo -e "\n\nSuccess - Exiting"
