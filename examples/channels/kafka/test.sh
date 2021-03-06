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
NS=examples-kafka

u::testsuite "Kafka"
k8s::create_and_set_ns $NS

cd $ROOT/examples/channels/kafka

[[ $(kubectl get ns kafka) ]] || (echo "installing strimzi"; kafka::install_strimzi)

echo "Connecting to my-cluster-kafka-bootstrap.kafka:9092."

u::header "Deploying..."

kubectl apply -f config/



