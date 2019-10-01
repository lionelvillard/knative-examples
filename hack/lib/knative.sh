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


# install Knative
function knative::install() {
  local serving_version=$1
  local eventing_version=$2

  local serving_base=https://github.com/knative/serving/releases/download/v${serving_version}
  local eventing_base=https://github.com/knative/eventing/releases/download/v${eventing_version}

  if [[ $serving_version == "" || $serving_version == "nightly" ]]; then
    echo "install knative serving nightly"
    serving_base=https://storage.googleapis.com/knative-nightly/serving/latest
  fi


  if [[ $eventing_version == "" || $eventing_version == "nightly" ]]; then
    echo "install knative eventing nightly"
    eventing_base=https://storage.googleapis.com/knative-nightly/eventing/latest
  fi

  u::header "installing knative CRDS"

  # there is a bug in kubectl .. must do it twice.
  set +e
  kubectl apply --selector knative.dev/crd-install=true -f ${serving_base}/serving.yaml
  kubectl apply --selector knative.dev/crd-install=true -f ${serving_base}/serving.yaml
  kubectl apply --selector knative.dev/crd-install=true -f ${eventing_base}/release.yaml
  set -e

  sleep 2

  u::header "installing knative"

  kubectl apply -f  ${serving_base}/serving.yaml
  k8s::wait_until_pods_running knative-serving

  kubectl apply -f ${eventing_base}/release.yaml
  k8s::wait_until_pods_running knative-eventing

  return 0
}

function knative::install_send_event() {
  if [[ -z $(kubectl get -n default ksvc dispatch-event 2> /dev/null) ]]; then
    pushd ${LIBROOT}/../../src
    cat << EOF | kone apply -f -
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: dispatch-event
  namespace: default
spec:
  template:
    spec:
      containers:
      - image: ./send-event
EOF
    popd
  fi
}

function knative::send_event() {
  local target=$1
  local event=$2
  if [[ $target == "" || $event == "" ]]; then
      u::fatal "missing argument. send_event <target> <event>"
  fi

  knative::install_send_event

  curl -v -H "host: dispatch-event.default.example.com" \
    -H "target: $target" \
    -H 'content-type: application/json' \
    -d $event \
    localhost:8080
}