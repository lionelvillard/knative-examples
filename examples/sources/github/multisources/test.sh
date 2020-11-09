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

ROOT=$(dirname $BASH_SOURCE[0])/../../../..
source $ROOT/hack/lib/library.sh
NS=mgh

u::testsuite "Github Source"
k8s::create_and_set_ns $NS

cd $ROOT/examples/sources/github/multisources

u::header "Deploying..."

cat config/secret/githubsecret.yaml | sed "s/GITHUB_TOKEN/${GITHUB_TOKEN}/" | kubectl apply --filename -
kubectl apply -f config/



