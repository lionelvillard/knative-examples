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

ROOT=$(dirname $BASH_SOURCE[0])/..
source $ROOT/hack/lib/library.sh
NS=examples-parallel

u::testsuite "Parallel"
k8s::create_and_set_ns $NS

cd $ROOT/examples/parallel

u::header "Deploying..."
kone apply -f config/

k8s::wait_resource_ready parallels.messaging.knative.dev check-assignment

target=$(kubectl get parallels.messaging.knative.dev check-assignment -o=jsonpath='{$.status.address.url}')

knative::send_event ${target:7} '{"assigned":true}' anid ansource atype
k8s::wait_log_contains "serving.knative.dev/configuration=send-message" user-container 'assignment received'

u::header "cleanup"
kubectl delete -f config
k8s::delete_ns $NS