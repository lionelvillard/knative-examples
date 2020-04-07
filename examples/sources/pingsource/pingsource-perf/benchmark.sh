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

ROOT=$(dirname $BASH_SOURCE[0])/../../../../
source $ROOT/hack/lib/library.sh
NS=perf-pingsource

u::testsuite "PingSources"
k8s::create_and_set_ns $NS

cd $ROOT/examples/sources/pingsource/pingsource-perf

u::header "Deploying 1000 pingsource"

kubectl apply -f event-display-svc.yaml

touch pingsources.yaml

for (( i = 0; i < 1000; ++i )); do
    cat hello-pingsource.yaml | sed "s/hello/hello-${i}/g" >> pingsources.yaml
    echo "---" >> pingsources.yaml
done
