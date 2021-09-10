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

id=${1:-"crn:v1:bluemix:public:messagehub:us-south:a/e3a470d882f9e5b9a59f4c98b6cb2b40:92f9c965-9b5d-474d-9310-a054ab745b21:resource-key:1576eda6-f153-435e-9e03-6e6947fa53ec"}
credentials=$(bx resource service-key "$id" --output json)
user=$(echo $credentials | jq -r ".[0].credentials.user")
password=$(echo $credentials | jq -r ".[0].credentials.password")

kubectl create secret  generic secret-eventstream --from-literal=user=$user --from-literal=password=$password -n sources-kafka-eventstream
