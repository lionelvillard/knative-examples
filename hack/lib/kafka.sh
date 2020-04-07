#!/usr/bin/env bash

# Copyright 2020 IBM Corporation
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


# install strimzi
function kafka::install_strimzi() {
  local strimzi_version=${1:-0.16.1}

  kubectl create ns kafka || return true

  curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/${strimzi_version}/strimzi-cluster-operator-${strimzi_version}.yaml \
  | sed 's/namespace: .*/namespace: kafka/' \
  | kubectl apply -f - -n kafka

  # Apply the `Kafka` Cluster CR file
  kubectl apply -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/${strimzi_version}/examples/kafka/kafka-ephemeral-single.yaml -n kafka

  kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka

  return 0
}
