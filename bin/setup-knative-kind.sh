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
source $ROOT/bin/lib/library.sh

KNATIVE_SERVING_VERSION=$1
KNATIVE_EVENTING_VERSION=$2
if [[ $KNATIVE_SERVING_VERSION == "" || $KNATIVE_EVENTING_VERSION == "" ]]; then
  u::fatal "usage: setup-knative-kind.sh <knative-serving-version> <knative-eventing-version>"
fi

PROFILE=knative-s${KNATIVE_SERVING_VERSION}-e${KNATIVE_EVENTING_VERSION}

# Check profile exists already
if [ "$(kind get clusters | grep ${PROFILE})" == "" ]; then
  kind::start $PROFILE
fi

kind::update-context $PROFILE
echo "targeting $(kubectl config current-context)"

istio::install_lean 1.1.7
knative::install $KNATIVE_SERVING_VERSION $KNATIVE_EVENTING_VERSION