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

# install Knative
function knative::install() {
  local serving_version=$1
  local eventing_version=$2

  if [[ $serving_version == "" ||  $eventing_version == "" ]]; then
    u::fatal "usage: knative::install <serving-version> <eventing-version>"
  fi

  u::header "installing knative CRDS"

  # there is a bug in kubectl .. must do it twice.
  set +e
  kubectl apply --selector knative.dev/crd-install=true -f https://github.com/knative/serving/releases/download/v${serving_version}/serving.yaml
  set -e
  kubectl apply --selector knative.dev/crd-install=true -f https://github.com/knative/serving/releases/download/v${serving_version}/serving.yaml
  kubectl apply --selector knative.dev/crd-install=true -f https://github.com/knative/eventing/releases/download/v${eventing_version}/release.yaml

  sleep 2

  u::header "installing knative"

  kubectl apply -f https://github.com/knative/serving/releases/download/v${serving_version}/serving.yaml
  # kubectl patch -n knative-serving deployments.apps istio-pilot -p '{"spec": {"template": {"spec": {"containers": [{"name": "discovery", "resources": {"requests": {"cpu":"100m"}}}]}}}}'

  set +e
  k8s::wait_until_pods_running knative-serving
  set -e
  kubectl logs -lapp=networking-istio -n knative-serving
  kubectl get pod -lapp=networking-istio -n knative-serving -oyaml

  kubectl apply -f https://github.com/knative/eventing/releases/download/v${eventing_version}/release.yaml
  k8s::wait_until_pods_running knative-eventing

  # kubectl apply -f  https://github.com/knative/serving/releases/download/v${serving_version}/monitoring.yaml
  # kubectl patch -n knative-monitoring statefulsets.apps prometheus-system -p '{"spec":{"replicas":1}}'
  # kubectl patch -n knative-monitoring statefulsets.apps elasticsearch-logging -p '{"spec":{"replicas":1}}'
  # kubectl delete -n knative-monitoring deployments.apps grafana
  # k8s::wait_until_pods_running knative-monitoring

  return 0
}