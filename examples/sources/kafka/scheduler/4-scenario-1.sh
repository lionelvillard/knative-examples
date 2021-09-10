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

NS=sources-kafka-scheduler

k8s::create_and_set_ns $NS

test::case "Test one KafkaSource scaling up and down, not reaching pods capacity"

kubectl apply -f config-1/topics

k8s::wait_resource_ready_ns KafkaTopic products kafka

kubectl apply -f config-1

k8s::wait_resource_ready KafkaSource products

placements=$(kubectl get kafkasources.sources.knative.dev products -ojsonpath="{.status.placements}")
count=$(echo $placements | jq '. | length')
if [[ $count != "1" ]]; then
  echo "expected one placement"
fi

echo "By scaling to 10 vreps"

kubectl scale --replicas=10 kafkasources/products
placements=$(kubectl get kafkasources.sources.knative.dev products -ojsonpath="{.status.placements}")
count=$(echo $placements | jq '. | length')
if [[ $count != "3" ]]; then
  echo "expected 3 placements"
fi


echo "By scaling to 3 vreps"

kubectl scale --replicas=3 kafkasources/products
placements=$(kubectl get kafkasources.sources.knative.dev products -ojsonpath="{.status.placements}")
count=$(echo $placements | jq '. | length')
if [[ $count != "3" ]]; then
  echo "expected 3 placements"
fi

echo cleanup
kubectl delete -f config-1
kubectl delete -f config-1/topics


test::pass


