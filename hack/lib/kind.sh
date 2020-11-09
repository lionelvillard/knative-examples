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

# Create kind cluster
function kind::start() {
  local name="$1"
  local config="$2"

  if [[ "$name" == "" ]]; then
    u::fatal "usage kind::create <name>: missing argument"
  fi

  local configflag=""
  if [[ "$config" != "" ]]; then
    configflag="--config"
  fi

  if [[ "$(kind get clusters | grep "${name}")" != "" ]]; then
    kubectx "kind-${name}" || echo 0
    set +e;  kubectl cluster-info 2>> /dev/null; set -e
    code=$?
    if [[ "$code" != "0" ]]; then
      kind delete cluster --name "${name}"
      kind create cluster --name "${name}" $configflag "${config}"
    fi
  else
      echo "creating new kind cluster"
      kind create cluster --name "${name}" $configflag "${config}"
  fi

  return 0
}
