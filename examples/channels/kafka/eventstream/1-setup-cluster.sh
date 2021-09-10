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

ROOT=$(dirname $BASH_SOURCE[0])/../../../..
source $ROOT/hack/lib/library.sh

#knative::install_eventing 0.19.0

# configure kafka

id=${1:-"crn:v1:bluemix:public:messagehub:us-south:a/9fe18499e7d53fe0d5b63ead02519393:193e8a63-4355-454c-b535-b9209035cb6b:resource-key:5223ff5b-ced7-4f7b-bc93-cac47f8de961"}
credentials=$(bx resource service-key "$id" --output json)
user=$(echo $credentials | jq -r ".[0].credentials.user")
password=$(echo $credentials | jq -r ".[0].credentials.password")

kubectl create secret generic secret-eventstream -n knative-eventing\
  --from-literal=user="$user"\
  --from-literal=password="$password"\
  --from-literal=saslType=PLAIN\
  --from-literal=tls.enabled=true

kafka::install_channel_no_config 0.19.2

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kafka
  namespace: knative-eventing
data:
  authSecretName: secret-eventstream
  authSecretNamespace: knative-eventing
  bootstrapServers: "broker-3-x47r3zptxcqmznyr.kafka.svc08.us-south.eventstreams.cloud.ibm.com:9093"
EOF

