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