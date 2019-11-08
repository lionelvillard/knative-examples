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
NS=examples-functions
k8s::create_and_set_ns $NS

u::testsuite "Function"

cd $ROOT/examples/functions

u::header "Deploying..."
kone apply -f config/identity-ksvc.yaml
kone apply -f config/wait-ksvc.yaml
kone apply -f config/config-wait.yaml

k8s::wait_resource_ready services.serving.knative.dev identity
k8s::wait_resource_ready services.serving.knative.dev wait

u::header "Testing..."

printf "should return same event"
resp=$(knative::invoke_service identity '{"msg": "hello"}')
if [[ $resp != '{"msg":"hello"}' ]]; then
    u::fatal "expected response ${resp}"
fi
printf "$CHECKMARK\n"

printf "should return same event after 2 seconds"
time=$(curl -sw "%{time_total}" -H "host: wait.examples-functions.example.com" localhost:8080?seconds=0 -d '{"msg": "hello"}') # warmup
time=$(curl -sw "%{time_total}" -H "host: wait.examples-functions.example.com" localhost:8080?seconds=2 -d '{"msg": "hello"}')
if [[ ${time:15:1} != '2' ]]; then
    u::fatal "expected time ${time}"
fi
printf "$CHECKMARK\n"

printf "should return same event after 1 seconds"
time=$(curl -sw "%{time_total}" -H "host: wait.examples-functions.example.com" localhost:8080 -d '{"msg": "hello"}')
if [[ ${time:15:1} != '1' ]]; then
    u::fatal "expected time ${time}"
fi
printf "$CHECKMARK\n"

u::header "cleanup..."
kubectl delete -f config
k8s::delete_ns $NS