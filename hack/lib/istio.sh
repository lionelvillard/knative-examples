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

function istio::install_lean() {
  local ISTIO_VERSION=$1

  if [[ "$ISTIO_VERSION" == "" ]]; then
    u::fatal "usage istio::install <istio_version>: missing argument"
  fi

  u::header "installing istio"
  ISTIO_DIR=$(mktemp -d)
  pushd $ISTIO_DIR

  export ISTIO_VERSION
  curl -L https://git.io/getLatestIstio | sh -
  cd istio-${ISTIO_VERSION}

  for i in install/kubernetes/helm/istio-init/files/crd*yaml; do
      kubectl apply -f $i;
  done

  sleep 2

  set +e
  kubectl create ns istio-system
  kubectl label ns istio-system istio-injection=disabled
  set -e

  helm template --namespace=istio-system \
    --set prometheus.enabled=false \
    --set mixer.enabled=false \
    --set mixer.policy.enabled=false \
    --set mixer.telemetry.enabled=false \
    `# Pilot doesn't need a sidecar.` \
    --set pilot.sidecar=false \
    --set pilot.resources.requests.memory=128Mi \
    --set pilot.resources.requests.cpu=100m \
    `# Disable galley (and things requiring galley).` \
    --set galley.enabled=false \
    --set global.useMCP=false \
    `# Disable security / policy.` \
    --set security.enabled=false \
    --set global.disablePolicyChecks=true \
    `# Disable sidecar injection.` \
    --set sidecarInjectorWebhook.enabled=false \
    --set global.proxy.autoInject=disabled \
    --set global.omitSidecarInjectorConfigMap=true \
    `# Set gateway pods to 1 to sidestep eventual consistency / readiness problems.` \
    --set gateways.istio-ingressgateway.autoscaleMin=1 \
    --set gateways.istio-ingressgateway.autoscaleMax=1 \
    `# Set pilot trace sampling to 100%` \
    --set pilot.traceSampling=100 \
    install/kubernetes/helm/istio \
    > ./istio-lean.yaml

  kubectl apply -f istio-lean.yaml
  # kubectl patch -n istio-system deployments.apps istio-pilot -p '{"spec": {"template": {"spec": {"containers": [{"name": "discovery", "resources": {"requests": {"cpu":"100m"}}}]}}}}'

  echo "install local cluster gateway"

  helm template --namespace=istio-system \
    --set gateways.custom-gateway.autoscaleMin=1 \
    --set gateways.custom-gateway.autoscaleMax=1 \
    --set gateways.custom-gateway.cpu.targetAverageUtilization=60 \
    --set gateways.custom-gateway.labels.app='cluster-local-gateway' \
    --set gateways.custom-gateway.labels.istio='cluster-local-gateway' \
    --set gateways.custom-gateway.type='ClusterIP' \
    --set gateways.istio-ingressgateway.enabled=false \
    --set gateways.istio-egressgateway.enabled=false \
    --set gateways.istio-ilbgateway.enabled=false \
    install/kubernetes/helm/istio \
    -f install/kubernetes/helm/istio/example-values/values-istio-gateways.yaml \
    | sed -e "s/custom-gateway/cluster-local-gateway/g" -e "s/customgateway/clusterlocalgateway/g" \
    > ./istio-local-gateway.yaml

  kubectl apply -f istio-local-gateway.yaml

  popd

  k8s::wait_until_pods_running istio-system

  return 0
}
