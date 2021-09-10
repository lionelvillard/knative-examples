#!/usr/bin/env bash

# Copyright 2019 IBM Corporation
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

set -e

ROOT=$(dirname $BASH_SOURCE[0])/../../../..
source $ROOT/hack/lib/library.sh

function cleanup() {
    if [ -z "$PID" ]; then
        kill $PID
    fi
}

function dump_memory() {
    alloc_str=$(curl -s localhost:9090/metrics | grep "kafkasource_go_alloc{")
    alloc=$(string::trim_right "${alloc_str}" "}")
    python3 -c 'print(f"{round('${alloc}'/1024)}")' # in Kb
}

function sample_memory() {
    local duration="${1:-50}"
    for i in $(seq 1 "$duration"); do
        mem=$(dump_memory)
        echo $mem
        sleep 5
    done
    echo $mem
}

trap cleanup EXIT SIGINT

NS=sources-kafka-memory
k8s::create_and_set_ns $NS

kubectl port-forward -n knative-eventing statefulset/kafkasource-mt-adapter 9090:9090 > /dev/null 2>&1 &
PID=$!
sleep 2

# Establishing baseline, no sources.
kb0=$(dump_memory)
u::header "no sources: ${kb0}Kb"

kubectl apply -f config-1/topic-1.yaml
kubectl apply -f config-1/topic-1-kafkasink.yaml
kubectl apply -f config-1/topic-1-event-sender.yaml
sleep 120
kubectl apply -f config-1
kb1_1=$(sample_memory)
kubectl delete -f config-1
u::header "1 source, 1 partition: ${kb1_1}Kb"

kubectl apply -f config-50/topic-50.yaml
kubectl apply -f config-50/topic-50-kafkasink.yaml
kubectl apply -f config-50/topic-50-event-sender.yaml
sleep 120
kubectl apply -f config-50
kb1_50=$(sample_memory)
kubectl delete -f config-50
u::header "1 source, 50 partitions: ${kb1_50}Kb"

kubectl apply -f config-100/topic-100.yaml
kubectl apply -f config-100/topic-100-kafkasink.yaml
kubectl apply -f config-100/topic-100-event-sender.yaml
sleep 120
kubectl apply -f config-100
kb1_100=$(sample_memory)
kubectl delete -f config-100
u::header "1 source, 100 partitions: ${kb1_100}Kb"


#kubectl apply -f config-300/topic-300.yaml
#sleep 10
#kubectl apply -f config-300
#sleep 10
#kb1_300=$(sample_memory)
#kubectl delete -f config-300
#u::header "1 source, 300 partitions: ${kb1_300}Kb"




