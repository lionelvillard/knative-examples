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

ROOT=$(dirname $BASH_SOURCE[0])/../..
source $ROOT/hack/lib/library.sh
NS=hello-retail
k8s::create_and_set_ns $NS

u::testsuite "Hello Retail"

cd $ROOT/examples/helloretail

u::header "Deploying..."
kone apply -f config/

k8s::wait_resource_ready services.serving.knative.dev assign
k8s::wait_resource_ready services.serving.knative.dev wait
k8s::wait_resource_ready services.serving.knative.dev check-assign
k8s::wait_resource_ready services.serving.knative.dev event-display
k8s::wait_resource_ready sequences.messaging.knative.dev assign-photographer
k8s::wait_resource_ready parallels.messaging.knative.dev check-assignment

u::header "Testing..."

host=$(kubectl get sequences.messaging.knative.dev assign-photographer -o=jsonpath='{$.status.address.url}')
data='{ "id": 4579874, "brand": "POLO RALPH LAUREN", "name": "Polo Ralph Lauren 3-Pack Socks", "description": "PAGE:/s/polo-ralph-lauren-3-pack-socks/4579874", "category": "Socks for Men" }'

knative::send_event ${host:7} "$data" 4579874 asource atype

k8s::wait_log_contains "serving.knative.dev/configuration=event-display" user-container '"id": 4579874,'

u::header "cleanup..."
kubectl delete -f config
k8s::delete_ns $NS