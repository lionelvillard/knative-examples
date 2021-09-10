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
  local openshift=${3:-no}

  local serving_base=https://github.com/knative/serving/releases/download/v${serving_version}
  local netistio_base=https://github.com/knative/net-istio/releases/download/v${serving_version}
  local eventing_base=https://github.com/knative/eventing/releases/download/v${eventing_version}
  local eventing_file=eventing
  local clone_root=$GOPATH/src/knative.dev

  if [[ eventing_version != "source" && $(semver::lt ${eventing_version} 0.12.0) ]]; then
    eventing_file=release
  fi

  if [[ $serving_version == "" || $serving_version == "nightly" ]]; then
    echo "install knative serving nightly"
    serving_base=https://storage.googleapis.com/knative-nightly/serving/latest
  fi

  if [[ $eventing_version == "" || $eventing_version == "nightly" ]]; then
    echo "install knative eventing nightly"
    eventing_base=https://storage.googleapis.com/knative-nightly/eventing/latest
  fi

  if [[ $eventing_version == "source" ]]; then
    echo "install knative eventing from source"
  fi

  if [[ $serving_version != "skip" ]]; then
    u::header "installing Knative Serving ${serving_version}"

    if [[ $(semver::lt ${serving_version} 0.16.0) ]]; then
      # there is a bug in kubectl .. must do it twice.
      set +e
      kubectl apply --selector knative.dev/crd-install=true -f ${serving_base}/serving.yaml
      kubectl apply --selector knative.dev/crd-install=true -f ${serving_base}/serving.yaml
      set -e
    else
      kubectl apply  -f ${serving_base}/serving-crds.yaml
    fi


    sleep 2

    if [[ $(semver::lt ${serving_version} 0.16.0) ]]; then
      kubectl apply -f  ${serving_base}/serving.yaml
    else
      kubectl apply -f  ${serving_base}/serving-core.yaml
      kubectl apply -f  ${netistio_base}/release.yaml
    fi

    k8s::wait_until_pods_running knative-serving
    kubectl patch -n knative-serving deployments.apps activator -p '{"spec": {"template": {"spec": {"containers": [{"name": "activator", "resources": {"requests": {"cpu":"50m"}}}]}}}}'

  fi

  echo "installing Knative Eventing ${eventing_version}"

  if [[ $eventing_version != "source" ]]; then
   kubectl apply --selector knative.dev/crd-install=true -f ${eventing_base}/${eventing_file}.yaml
  fi

  if [[ "$eventing_version" == "source" ]]; then
    echo "installing Knative from source ${clone_root}/eventing"
    pushd ${clone_root}/eventing
    ko apply -f config
    ko apply -f config/channels/in-memory-channel/
    ko apply -f config/brokers/mt-channel-broker/
    ko apply -f config/sugar/
    popd
  else
    if [[ $(semver::lt ${eventing_version} 0.16.0) ]]; then
      kubectl apply -f ${eventing_base}//${eventing_file}.yaml
    else
      kubectl apply -f ${eventing_base}/eventing-crds.yaml
      kubectl apply -f ${eventing_base}/eventing-core.yaml
      kubectl apply -f ${eventing_base}/in-memory-channel.yaml
      kubectl apply -f ${eventing_base}/mt-channel-broker.yaml
    fi
  fi
  kubectl patch -n knative-eventing deployments.apps imc-dispatcher -p '{"spec": {"template": {"spec": {"containers": [{"name": "dispatcher", "resources": {"requests": {"cpu":"50m"}}}]}}}}'
  kubectl patch -n knative-eventing deployments.apps eventing-webhook -p '{"spec": {"template": {"spec": {"containers": [{"name": "eventing-webhook", "env": [{"name": "SINK_BINDING_SELECTION_MODE", "value": "inclusion"}]}]}}}}'

  k8s::wait_until_pods_running knative-eventing
  return 0
}

function knative::install_serving() {
  local version=${1:-0.22.0}
  local clone_root=$GOPATH/src/knative.dev

  if [[ $version == "" || $version == "nightly" ]]; then
    echo "install knative serving nightly"
    eventing_base=https://storage.googleapis.com/knative-nightly/serving/latest
  fi

  if [[ $version == "source" ]]; then
    echo "install knative serving from source"
  fi

  echo "installing Knative Serving ${version}"

  if [[ $version != "source" ]]; then
    kubectl apply -f https://github.com/knative/serving/releases/download/v${version}/serving-crds.yaml
  fi

  if [[ "$version" == "source" ]]; then
    echo "installing Knative from source ${clone_root}/serving"
    pushd ${clone_root}/serving
    ko apply -f config
    popd
  else
    kubectl apply -f https://github.com/knative/serving/releases/download/v${version}/serving-crds.yaml
    kubectl apply -f https://github.com/knative/serving/releases/download/v${version}/serving-core.yaml
    kubectl apply -f https://github.com/knative/net-kourier/releases/download/v${version}/kourier.yaml
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'

    KNATIVE_DOMAIN=127.0.0.1.nip.io
    kubectl patch configmap -n knative-serving config-domain -p "{\"data\": {\"$KNATIVE_DOMAIN\": \"\"}}"

    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: kourier-ingress
  namespace: kourier-system
  labels:
    networking.knative.dev/ingress-provider: kourier
spec:
  type: NodePort
  selector:
    app: 3scale-kourier-gateway
  ports:
    - name: http2
      nodePort: 31080
      port: 80
      targetPort: 8080
EOF

  fi

  k8s::wait_until_pods_running knative-serving
  return 0
}


function knative::install_eventing() {
  local eventing_version=${1:-0.22.0}

  local eventing_base=https://github.com/knative/eventing/releases/download/v${eventing_version}
  local eventing_file=eventing
  local clone_root=$GOPATH/src/knative.dev

  if [[ $eventing_version == "" || $eventing_version == "nightly" ]]; then
    echo "install knative eventing nightly"
    eventing_base=https://storage.googleapis.com/knative-nightly/eventing/latest
  fi

  if [[ $eventing_version == "source" ]]; then
    echo "install knative eventing from source"
  fi

  echo "installing Knative Eventing ${eventing_version}"

  if [[ $eventing_version != "source" ]]; then
   kubectl apply --selector knative.dev/crd-install=true -f ${eventing_base}/${eventing_file}.yaml
  fi

  if [[ "$eventing_version" == "source" ]]; then
    echo "installing Knative from source ${clone_root}/eventing"
    pushd ${clone_root}/eventing
    ko apply -f config
    ko apply -f config/channels/in-memory-channel/
    ko apply -f config/brokers/mt-channel-broker/
    popd
  else
    if [[ $(semver::lt ${eventing_version} 0.16.0) ]]; then
      kubectl apply -f ${eventing_base}//${eventing_file}.yaml
    else
      kubectl apply -f ${eventing_base}/eventing-crds.yaml
      kubectl apply -f ${eventing_base}/eventing.yaml
    fi
  fi
  # kubectl patch -n knative-eventing deployments.apps eventing-webhook -p '{"spec": {"template": {"spec": {"containers": [{"name": "eventing-webhook", "env": [{"name": "SINK_BINDING_SELECTION_MODE", "value": "inclusion"}]}]}}}}'

  k8s::wait_until_pods_running knative-eventing
  return 0
}

function knative::install_eventing_crds() {
  local eventing_version=${1:-0.21.0}
  local eventing_base=https://github.com/knative/eventing/releases/download/v${eventing_version}
  kubectl apply --selector knative.dev/crd-install=true -f ${eventing_base}/eventing.yaml
}

function knative::install_sugar() {
  local eventing_version=${1:-0.20.1}

  local eventing_base=https://github.com/knative/eventing/releases/download/v${eventing_version}
  local eventing_file=eventing
  local clone_root=$GOPATH/src/knative.dev

  if [[ $eventing_version == "" || $eventing_version == "nightly" ]]; then
    echo "install knative eventing sugar controller nightly"
    eventing_base=https://storage.googleapis.com/knative-nightly/eventing/latest
  fi

  if [[ $eventing_version == "source" ]]; then
    echo "install knative eventing sugar controller from source"
  fi

  echo "installing Knative Eventing sugar controller ${eventing_version}"


  if [[ "$eventing_version" == "source" ]]; then
    echo "installing Knative from source ${clone_root}/eventing"
    pushd ${clone_root}/eventing
    ko apply -f config/sugar/
    popd
  else
    kubectl apply -f ${eventing_base}/eventing-sugar-controller.yaml
  fi

  k8s::wait_until_pods_running knative-eventing
  return 0
}


# install Knative-function (not part of base knative)
function knative::install_functions() {
  local version=$1

  local base=https://github.com/lionelvillard/knative-functions-controller/releases/download/v${version}

  u::header "installing knative functions"

  kubectl apply -f  ${base}/function.yaml
  k8s::wait_until_pods_running knative-functions
}

function knative::install_send_event() {
  if [[ -z $(kubectl get -n default ksvc dispatch-event 2> /dev/null) ]]; then
    pushd ${LIBROOT}/../../src
    cat << EOF | kone apply -f -
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: dispatch-event
  namespace: default
spec:
  template:
    spec:
      containers:
      - image: ./send-event
EOF
    popd

    k8s::wait_resource_ready_ns services.serving.knative.dev dispatch-event default
  fi

  if [[ -z "${DISPATCH_URL:-}" ]]; then
    DISPATCH_URL=$(kubectl get ksvc dispatch-event -n default -o 'jsonpath={.status.url}')
    DISPATCH_URL=${DISPATCH_URL:7}
  fi
}

# send event to the given target channel.
# rely on an helper service, dispath-event to access non-exposed channels.
# Only work for kind cluster
function knative::send_event() {
  local target=$1
  local event=$2  # event data
  local eid=$3   # event id  https://github.com/cloudevents/spec/blob/v1.0/spec.md#id
  local esource=$4   # event source https://github.com/cloudevents/spec/blob/v1.0/spec.md#source-1
  local etype=$5 # event type  https://github.com/cloudevents/spec/blob/v1.0/spec.md#type
  if [[ $target == "" || $event == "" || $eid == "" || $esource == "" || $etype == "" ]]; then
      u::fatal "missing argument. send_event <target> <event> <id> <source> <type>"
  fi

  knative::install_send_event

  if [[ -z "${ISTIO_IP_ADDRESS:-}" ]]; then
    ISTIO_IP_ADDRESS=$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.status.loadBalancer.ingress[0].ip}')
    if [[ -z "${ISTIO_IP_ADDRESS:-}" ]]; then
      ISTIO_IP_ADDRESS=localhost:8080
    fi
  fi

  curl -s -H "host: dispatch-event.default.example.com" \
    -H "target: $target" \
    -H "content-type: application/json" \
    -H "ce-id: ${eid}" \
    -H "ce-source: ${esource}" \
    -H "ce-type: ${etype}" \
    -H "ce-specversion: 0.3" \
    -d "$event" \
    http://${ISTIO_IP_ADDRESS}
}

function knative::send_event_ingress() {
  knative::send_event $*
}

function knative::invoke_service() {
  local name="$1"
  local body="$2"
  local query="${3:-}"

  local url=$(kubectl get ksvc $name -o 'jsonpath={.status.url}')
  knative::invoke ${url:7} "$body" "$query"
}

function knative::invoke_service_time() {
  local name="$1"
  local body="$2"
  local query="${3:-}"

  local url=$(kubectl get ksvc $name -o 'jsonpath={.status.url}')
  knative::invoke_time ${url:7} "$body" "$query"
}

function knative::invoke() {
  local host="$1"
  local body="$2"
  local query="${3:-}"

  if [[ -z "${ISTIO_IP_ADDRESS:-}" ]]; then
    ISTIO_IP_ADDRESS=$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.status.loadBalancer.ingress[0].ip}')
    if [[ -z "${ISTIO_IP_ADDRESS:-}" ]]; then
      ISTIO_IP_ADDRESS=localhost:8080
    fi
  fi

  local data=
  if [[ -n ${body} ]]; then
    data="-d ${body}"
  fi

  local querystr=
  if [[ -n ${query} ]]; then
    querystr="?${query}"
  fi

  curl -s -X POST -H "Host: $host" http://${ISTIO_IP_ADDRESS}${querystr} "$data"
}

# Same as invoke. Return response and time
function knative::invoke_time() {
  local host="$1"
  local body="$2"
  local query="${3:-}"

  if [[ -z "${ISTIO_IP_ADDRESS:-}" ]]; then
    ISTIO_IP_ADDRESS=$(kubectl get svc istio-ingressgateway --namespace istio-system --output 'jsonpath={.status.loadBalancer.ingress[0].ip}')
    if [[ -z "${ISTIO_IP_ADDRESS:-}" ]]; then
      ISTIO_IP_ADDRESS=localhost:8080
    fi
  fi

  local data=
  if [[ -n ${body} ]]; then
    data="-d ${body}"
  fi

  local querystr=
  if [[ -n ${query} ]]; then
    querystr="?${query}"
  fi

  curl -sw "%{time_total}" -X POST -H "Host: $host" http://${ISTIO_IP_ADDRESS}${querystr} "$data"
}

