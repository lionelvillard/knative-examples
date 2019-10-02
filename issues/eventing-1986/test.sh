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
ROOT=$(dirname $BASH_SOURCE[0])/../..
source $ROOT/hack/lib/library.sh
ROOT=$(u::abs_path $ROOT)

# 0.9.0 moves subscription in messaging
if [[ $(semver::gte "${eventing_version}" 0.9.0) ]]; then
    pushd $ROOT/issues/eventing-1986

    kubectl apply -f .

    k8s::wait_log_contains "serving.knative.dev/configuration=issue-1986" user-container boo

    popd
fi
