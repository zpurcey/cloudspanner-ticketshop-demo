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

CLUSTER_PREFIX=spannerdemo-
#Update primary_region for 'us' 'asia' or 'europe'
primary_region='europe'

date

#Monitor venue load
while true; do
    kubectlout=$(kubectl --context $CLUSTER_PREFIX$primary_region-01 get job spannerdemo-venuesload)

    regex="spannerdemo-venuesload[[:space:]]+([0-9]*)[[:space:]]+([0-9]*)"
    if [[ $kubectlout =~ $regex ]];
    then
        echo "checking if venues load job is finished..."
        if [[ ${BASH_REMATCH[1]} == ${BASH_REMATCH[2]} ]];
        then
            echo "Venues load job finished"
            break
        fi
    fi
    echo "waiting 5 sec before next check..."
    sleep 5
done

#Monitor ticket load
while true; do
    kubectlout=$(kubectl --context $CLUSTER_PREFIX$primary_region-01 get job spannerdemo-ticketsload)

    regex="spannerdemo-ticketsload[[:space:]]+([0-9]*)[[:space:]]+([0-9]*)"
    if [[ $kubectlout =~ $regex ]];
    then
        echo "checking if ticket load job is finished..."
        if [[ ${BASH_REMATCH[1]} == ${BASH_REMATCH[2]} ]];
        then
            echo "Tickets load job finished"
            break
        fi
        echo "${BASH_REMATCH[2]} out of ${BASH_REMATCH[1]} finished"
    fi
    echo "waiting 1 minute before next check..."
    sleep 60
done

date
