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

test::case "Create KafkaSource pointing to missing sink then add sink"

kubectl apply -f config-1.1/topics

kubectl apply -f config-1.1/products-kafkasource.yaml
sleep 1

kubectl apply -f config-1.1/event-display.yaml

k8s::wait_resource_ready kafkasources products

placements=$(kubectl get kafkasources.sources.knative.dev products -ojsonpath="{.status.placements}")
count=$(echo $placements | jq '. | length')
if [[ $count != "3" ]]; then
  echo "expected three placement, got $count"
  test::fail
fi

echo cleanup
kubectl delete -f config-1.1
kubectl delete -f config-1.1/topics

test::pass


