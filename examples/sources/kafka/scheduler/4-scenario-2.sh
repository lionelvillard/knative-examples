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

test::case "Given several KafkaSource spread across multiple pods, add new source and scale up and down and delete"

kubectl apply -f config-2/topics
kubectl apply -f config-2/event-display.yaml


kubectl apply -f config-2/products-1-kafkasource.yaml
k8s::wait_resource_ready KafkaSource products-1

kubectl apply -f config-2/products-2-kafkasource.yaml
k8s::wait_resource_ready KafkaSource products-2

kubectl apply -f config-2/products-3-kafkasource.yaml
k8s::wait_resource_ready KafkaSource products-3

placements=$(kubectl get kafkasources.sources.knative.dev products-1 -ojsonpath="{.status.placements}")
count=$(echo $placements | jq '. | length')
if [[ $count != "3" ]]; then
  echo "expected three placement, got $count"
  test::fail
fi

echo cleanup
kubectl delete -f config-2
kubectl delete -f config-2/topics

test::pass


