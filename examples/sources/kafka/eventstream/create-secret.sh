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

id=${1:-"crn:v1:bluemix:public:messagehub:us-south:a/9fe18499e7d53fe0d5b63ead02519393:a45803b6-525d-4aa5-82bf-c00176c4e821:resource-key:bc0d4719-9015-4e01-89f3-645ce0cd8c6e"}
credentials=$(bx resource service-key "$id" --output json)
user=$(echo $credentials | jq -r ".[0].credentials.user")
password=$(echo $credentials | jq -r ".[0].credentials.password")

kubectl create secret  generic secret-eventstream --from-literal=user=$user --from-literal=password=$password -n sources-kafka-eventstream
