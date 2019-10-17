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

function ic::install_seed_operators() {
  local cloudversion=$1

  if [[ $cloudversion == ""   ]]; then
    echo "install seed latest"
    cloud_base=https://raw.githubusercontent.com/IBM/cloud-operators/master/releases/v0.1.2/
  fi

  kubectl apply -f ${cloud_base}/000_namespace.yaml
  kubectl apply -f ${cloud_base}/001_ibmcloud_v1alpha1_binding.yaml
  kubectl apply -f ${cloud_base}/002_ibmcloud_v1alpha1_service.yaml
  kubectl apply -f ${cloud_base}/003_serviceaccount.yaml
  kubectl apply -f ${cloud_base}/004_manager_role.yaml
  kubectl apply -f ${cloud_base}/005_rbac_role_binding.yaml
  kubectl apply -f ${cloud_base}/006_deployment.yaml

  k8s::wait_until_pods_running ibmcloud-operators

  return 0
}

function ic::configure_operators() {
  local apikey=$1
  local region=$2

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: seed-secret
  labels:
    seed.ibm.com/ibmcloud-token: "apikey"
    app.kubernetes.io/name: ibmcloud-operator
type: Opaque
stringData:
  api-key: ${apikey}
  region: ${region}
EOF

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: seed-defaults
  labels:
    app.kubernetes.io/name: ibmcloud-operator
data:
  org: org
  region: ${region}
  resourceGroup: default
  space: space
EOF

  return 0
}