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

ROOT=$(dirname $BASH_SOURCE[0])/../../..
source $ROOT/hack/lib/library.sh
NS=examples-broker-dls
k8s::create_and_set_ns $NS

u::testsuite "Broker-Trigger with Dead Letter Sink"

cd $ROOT/examples/broker/deadlettersink

u::header "Deploying..."

kubectl -n $NS create serviceaccount eventing-broker-ingress || true
kubectl -n $NS create serviceaccount eventing-broker-filter || true

kubectl -n $NS create rolebinding eventing-broker-ingress \
  --clusterrole=eventing-broker-ingress \
  --serviceaccount=$NS:eventing-broker-ingress || true
kubectl -n $NS create rolebinding eventing-broker-filter \
  --clusterrole=eventing-broker-filter \
  --serviceaccount=$NS:eventing-broker-filter || true

kubectl -n knative-eventing create rolebinding eventing-config-reader-$NS-eventing-broker-ingress \
  --clusterrole=eventing-config-reader \
  --serviceaccount=$NS:eventing-broker-ingress || true
kubectl -n knative-eventing create rolebinding eventing-config-reader-$NS-eventing-broker-filter \
  --clusterrole=eventing-config-reader \
  --serviceaccount=$NS:eventing-broker-filter || true

kubectl apply -f config
k8s::wait_until_pods_running $NS

target=$(kubectl get brokers.eventing.knative.dev custom -o=jsonpath='{$.status.address.hostname}')
knative::send_event $target '{"assigned":true}' anid ansource dev.knative.event

k8s::wait_log_contains "serving.knative.dev/configuration=event-display" user-container dev.knative.event

u::header "cleanup"
kubectl delete -f config
#k8s::delete_ns $NS
