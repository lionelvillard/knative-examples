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

cd $ROOT/flow/sequence
dirs=./src/*
for d in $dirs
do
    name=$(basename $d)
    (cd src/$name && npm i)
done

kubectl config set-context --current --namespace=examples-sequence
kone apply -f config/

sleep 5

kubectl -n examples-sequence get pods
kubectl -n examples-sequence get sequences.messaging.knative.dev
kubectl -n examples-sequence get ksvc

set +e
k8s::wait_log_contains "serving.knative.dev/configuration=event-display" user-container photographers

kubectl -n knative-eventing logs -lmessaging.knative.dev/channel=in-memory-channel

u::header "cleanup"
kubectl delete ns examples-sequence

