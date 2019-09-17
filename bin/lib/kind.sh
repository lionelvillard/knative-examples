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
  local name=$1

  if [[ "$name" == "" ]]; then
    u::fatal "usage kind::create <name>: missing argument"
  fi

  u::header "starting kind"
  kind create cluster --name $name
  return 0
}

function kind::update-context() {
  local name=$1

  if [[ "$name" == "" ]]; then
    u::fatal "usage kind::update-context <name>: missing argument"
  fi

  export KUBECONFIG="$(kind get kubeconfig-path --name=$name)"
}