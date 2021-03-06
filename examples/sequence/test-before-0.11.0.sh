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
NS=examples-sequence

u::testsuite "Sequence - prior 0.11.0"
k8s::create_and_set_ns $NS

cd $ROOT/examples/sequence

u::header "Deploying V1"

kone apply -f config/before-0.11.0/

sleep 5

k8s::wait_log_contains "serving.knative.dev/configuration=event-display" user-container photographers

# Failing in 0.9.0 and before
# u::header "Changing Service step 1"
# kone apply -f config/v2
# k8s::wait_log_contains "serving.knative.dev/configuration=event-display" user-container john1505

# Failing in 0.9.0 and before
u::header "Deleting step 3"
#kone apply -f config/v3
# k8s::wait_log_contains "serving.knative.dev/configuration=event-display" user-container john1505

u::header "cleanup"
kubectl delete -f config
k8s::delete_ns $NS
