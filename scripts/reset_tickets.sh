#!/bin/bash
# Copyright 2018 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
CLUSTER_PREFIX='spannerdemo-'
primary_region='us'

echo -e "\n\nTurning off all buy bots"
scripts/buybots_scale.sh 1 0
echo -e "${CHECK_MARK} Turning off all buy bots"

#Delete old job if it still exists and ignore not found error
echo -e "\n\nDeleting old reset job"
kubectl --context ${CLUSTER_PREFIX}${primary_region}-01 delete job ${CLUSTER_PREFIX}reset --ignore-not-found
echo -e "${CHECK_MARK} Deleting old reset job"

#Start Reset tickets job
echo -e "\n\nStarting ticket reset job"
kubectl --context ${CLUSTER_PREFIX}${primary_region}-01 create -f `ls k8sgenerated/*reset*`
echo -e "${CHECK_MARK} Starting ticket reset job"

echo -e "\n"

start=$SECONDS
while true; do
    kubectlout=$(kubectl --context ${CLUSTER_PREFIX}${primary_region}-01 get job ${CLUSTER_PREFIX}reset)
    regex="spannerdemo-reset[[:space:]]+([0-9]*)[[:space:]]+([0-9]*)"
    if [[ $kubectlout =~ $regex ]];
    then
        if [[ ${BASH_REMATCH[1]} == ${BASH_REMATCH[2]} ]];
        then
            echo -ne "\e[0K\rWaiting for job to complete. Duration: $duration s (${BASH_REMATCH[2]} out of ${BASH_REMATCH[1]} finished)"
            echo -e "\n${CHECK_MARK} Ticket reset job complete!"
            break
        fi
        end=$SECONDS
        duration=$(( end - sstart ))
        echo -ne "\e[0K\rWaiting for job to complete. Duration: $duration s (${BASH_REMATCH[2]} out of ${BASH_REMATCH[1]} finished)"
    fi
    sleep 2
done

#Reset Dashboard and Metrics
echo -e "\n\nReseting metrics and clearing the dashboard"
kubectl --context ${CLUSTER_PREFIX}${primary_region}-01 scale deployment ${CLUSTER_PREFIX}backend-influxdb --replicas 0
kubectl --context ${CLUSTER_PREFIX}${primary_region}-01 scale deployment ${CLUSTER_PREFIX}dashboard --replicas 0kkkkkjjj
