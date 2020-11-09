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
  local strimzi_version=${1:-0.18.0}

  kubectl create ns kafka || return 0

  # cluster operator only watching kafka namespace
  curl -L https://github.com/strimzi/strimzi-kafka-operator/releases/download/${strimzi_version}/strimzi-cluster-operator-${strimzi_version}.yaml |
    sed 's/namespace: .*/namespace: kafka/' |
    kubectl apply -f - -n kafka

  sleep 5
  while echo && kubectl get pods -n kafka | grep -v -E "(Running|Completed|STATUS)"; do sleep 5; done

  # Apply the `Kafka` Cluster CR file
  kubectl apply -f https://raw.githubusercontent.com/strimzi/strimzi-kafka-operator/${strimzi_version}/examples/kafka/kafka-ephemeral-single.yaml -n kafka

  kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka

  return 0
}

function kafka::install_source() {
  local version=${1:-0.18.0}

  if [ "$version" == "nightly" ]; then
    kubectl apply -f https://storage.googleapis.com/knative-nightly/eventing-kafka/latest/source.yaml
  elif [ "$version" == "source" ]; then
    pushd $GOPATH/src/knative.dev/eventing-kafka
    ko apply -f config/source
    popd
  elif [ "$version" == "mtsource" ]; then
    pushd $GOPATH/src/knative.dev/eventing-kafka
    ko apply -f config/source/multi
    popd
  elif [ "$version" == "stsource" ]; then
    pushd $GOPATH/src/knative.dev/eventing-kafka
    ko apply -f config/source/single
    popd
  else
    kubectl create ns knative-eventing || echo 0 # due to bug
    kubectl apply -f https://github.com/knative/eventing-contrib/releases/download/v${version}/kafka-source.yaml
  fi
}

function kafka::install_sink() {
  kubectl create ns knative-eventing || true

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-logging
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
    knative.dev/config-propagation: original
    knative.dev/config-category: eventing
data:
  # Common configuration for all Knative codebase
  zap-logger-config: |
    {
      "level": "info",
      "development": false,
      "outputPaths": ["stdout"],
      "errorOutputPaths": ["stderr"],
      "encoding": "json",
      "encoderConfig": {
        "timeKey": "ts",
        "levelKey": "level",
        "nameKey": "logger",
        "callerKey": "caller",
        "messageKey": "msg",
        "stacktraceKey": "stacktrace",
        "lineEnding": "",
        "levelEncoder": "",
        "timeEncoder": "iso8601",
        "durationEncoder": "",
        "callerEncoder": ""
      }
    }

  # Log level overrides
  # For all components changes are be picked up immediately.
  loglevel.controller: "info"
  loglevel.webhook: "info"
EOF

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: kafka-sink-config-logging
  namespace: knative-eventing
  labels:
    eventing.knative.dev/release: devel
    knative.dev/config-propagation: original
    knative.dev/config-category: eventing
data:
  # Common configuration for all Knative codebase
  zap-logger-config: |
    {
      "level": "info",
      "development": false,
      "outputPaths": ["stdout"],
      "errorOutputPaths": ["stderr"],
      "encoding": "json",
      "encoderConfig": {
        "timeKey": "ts",
        "levelKey": "level",
        "nameKey": "logger",
        "callerKey": "caller",
        "messageKey": "msg",
        "stacktraceKey": "stacktrace",
        "lineEnding": "",
        "levelEncoder": "",
        "timeEncoder": "iso8601",
        "durationEncoder": "",
        "callerEncoder": ""
      }
    }

  # Log level overrides
  # For all components changes are be picked up immediately.
  loglevel.controller: "info"
  loglevel.webhook: "info"
EOF

  kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/v0.18.1/eventing-kafka-controller.yaml
  kubectl apply -f https://github.com/knative-sandbox/eventing-kafka-broker/releases/download/v0.18.1/eventing-kafka-sink.yaml
}

function kafka::install_channel() {
  local version=${1:-nightly}

  kubectl create ns knative-eventing || true

  if [ "$version" == "nightly" ]; then
    kubectl apply -f https://storage.googleapis.com/knative-nightly/eventing-kafka/latest/channel-consolidated.yaml
  elif [ "$version" == "source" ]; then
    pushd $GOPATH/src/knative.dev/eventing-kafka
    ko apply -f config/channel/consolidated/
    popd
  fi

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kafka
  namespace: knative-eventing
data:
  # Broker URL. Replace this with the URLs for your kafka cluster,
  # which is in the format of my-cluster-kafka-bootstrap.my-kafka-namespace:9092.
  bootstrapServers: my-cluster-kafka-bootstrap.kafka:9092
EOF

  k8s::wait_until_pods_running knative-eventing
}

function kafka::install_distributed_channel() {
  local version=${1:-nightly}

  if [ "$version" == "nightly" ]; then
    kubectl apply -f https://storage.googleapis.com/knative-nightly/eventing-kafka/latest/channel-distributed.yaml
  elif [ "$version" == "source" ]; then
    pushd $GOPATH/src/knative.dev/eventing-kafka
    ko apply -f config/channel/distributed/
    popd
  fi

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kafka-cluster
  namespace: knative-eventing
stringData:
  # Broker URL. Replace this with the URLs for your kafka cluster,
  # which is in the format of my-cluster-kafka-bootstrap.my-kafka-namespace:9092.
  brokers: http://my-cluster-kafka-bootstrap.kafka:9092
  username: ""
  password: ""
EOF

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-eventing-kafka
  namespace: knative-eventing
data:
  eventing-kafka: |
    receiver:
      cpuLimit: 200m
      cpuRequest: 100m
      memoryLimit: 100Mi
      memoryRequest: 50Mi
      replicas: 1
    dispatcher:
      cpuLimit: 500m
      cpuRequest: 300m
      memoryLimit: 128Mi
      memoryRequest: 50Mi
      replicas: 1
    kafka:
      topic:
        defaultNumPartitions: 4
        defaultReplicationFactor: 1 # Cannot exceed the number of Kafka Brokers!
        defaultRetentionMillis: 604800000  # 1 week
      adminType: kafka # One of "kafka", "azure", "custom"
  sarama: |
    Version: 2.0.0 # Kafka Version Compatibility From Sarama's Supported List (Major.Minor.Patch)
    Admin:
      Timeout: 10000000000  # 10 seconds
    Net:
      KeepAlive: 30000000000  # 30 seconds
      MaxOpenRequests: 1 # Set to 1 for use with Idempotent Producer
      TLS:
        Enable: false
      SASL:
        Enable: false
        Mechanism: PLAIN
        Version: 1
    Metadata:
      RefreshFrequency: 300000000000  # 5 minutes
    Consumer:
      Offsets:
        AutoCommit:
          Interval: 5000000000  # 5 seconds
        Retention: 604800000000000  # 1 week
    Producer:
      Idempotent: true  # Must be false for Azure EventHubs
      RequiredAcks: -1  # -1 = WaitForAll, Most stringent option for "at-least-once" delivery.
EOF

  k8s::wait_until_pods_running knative-eventing
}
