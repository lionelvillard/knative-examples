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


# install keda
function keda::install_keda() {
  kubectl apply -f https://github.com/kedacore/keda/releases/download/v2.1.0/keda-2.1.0.yaml
  return 0
}

function keda::install_eventing_keda() {
  local version=${1:-0.21.0}

  local base=https://github.com/knative-sandbox/eventing-autoscaler-keda/releases/download/v${version}
  local file=autoscaler-keda.yaml
  local clone_root=$GOPATH/src/knative.dev

  if [[ $version == "" || $version == "nightly" ]]; then
    echo "install eventing autoscaler keda nightly"
    base=https://storage.googleapis.com/knative-nightly/eventing-autoscaler-keda/latest
  fi

  if [[ $version == "source" ]]; then
    echo "install eventing autoscaler keda from source"
    pushd $GOPATH/src/knative.dev/eventing-autoscaler-keda/
    ko apply -f config
    popd
  else
      echo "installing eventing autoscaler keda ${version}"
      kubectl apply -f ${base}/autoscaler-keda.yaml
  fi

  k8s::wait_until_pods_running eventing-autoscaler-keda
  return 0
}
