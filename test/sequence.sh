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

u::testsuite "Sequence"

[[ $(kubectl get ns | grep examples-sequence) == "" ]] && kubectl create ns examples-sequence

kubectl config set-context --current --namespace=examples-sequence
kone apply -f config/

sleep 5

k8s::wait_log_contains "serving.knative.dev/configuration=event-display" user-container photographers

u::header "cleanup"
kubectl delete ns examples-sequence --wait=false