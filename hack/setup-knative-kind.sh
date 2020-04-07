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

ROOT=$(dirname $BASH_SOURCE[0])/..
source $ROOT/hack/lib/library.sh

KNATIVE_SERVING_VERSION=$1
KNATIVE_EVENTING_VERSION=$2
if [[ $KNATIVE_SERVING_VERSION == "" || $KNATIVE_EVENTING_VERSION == "" ]]; then
  u::fatal "usage: setup-knative-kind.sh <knative-serving-version> <knative-eventing-version>"
fi

PROFILE=knative-s${KNATIVE_SERVING_VERSION}-e${KNATIVE_EVENTING_VERSION}

# Check profile exists already
if [[ "$(kind get clusters | grep ${PROFILE})" != "" ]]; then
  kind::update-context $PROFILE
  set +e;  kubectl cluster-info 2>> /dev/null; set -e
  code=$?
  if [[ code != 0 ]]; then
    kind delete cluster --name $PROFILE
    kind create cluster --name $PROFILE --config $ROOT/hack/kind-config.yaml
  fi
else
    kind create cluster --name $PROFILE --config $ROOT/hack/kind-config.yaml
fi

kind::update-context $PROFILE
echo "targeting $(kubectl config current-context)"

istio::install_lean 1.3.6
knative::install $KNATIVE_SERVING_VERSION $KNATIVE_EVENTING_VERSION
knative::install_functions 0.1.0

echo To access your newly created cluster, run:
echo export KUBECONFIG="$(kind get kubeconfig-path --name=knative-s${KNATIVE_SERVING_VERSION}-e${KNATIVE_EVENTING_VERSION})"
