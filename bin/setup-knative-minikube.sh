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

ISTIO_VERSION=${ISTIO_VERSION:-1.1.7}

KNATIVE_VERSION=$1
if [[ $KNATIVE_VERSION == "" ]]; then
  echo "usage: install-knative-minikube.sh <knative-version>"
  exit 1
fi

VM_DRIVER=kvm2
if [[ "$(uname)" == "Darwin" ]]; then
    VM_DRIVER=hyperkit
fi

echo "starting minikube"
minikube start --memory=12288 --cpus=6 --kubernetes-version=v1.15.2 \
    --vm-driver=$VM_DRIVER --disk-size=30g \
    -p knative-${KNATIVE_VERSION} \
    --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"

echo "installing istio"
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

popd


echo "installing knative CRDS"
kubectl apply --selector knative.dev/crd-install=true \
   --filename https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/serving.yaml \
   --filename https://github.com/knative/eventing/releases/download/v${KNATIVE_VERSION}/release.yaml \
   --filename https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/monitoring.yaml

sleep 2

echo "installing knative"
kubectl apply \
   --filename https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/serving.yaml \
   --filename https://github.com/knative/eventing/releases/download/v${KNATIVE_VERSION}/release.yaml \
   --filename https://github.com/knative/serving/releases/download/v${KNATIVE_VERSION}/monitoring.yaml
