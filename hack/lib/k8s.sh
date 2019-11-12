#!/usr/bin/env bash
#
# Copyright 2019 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function k8s::install_kubectl() {
      curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
      chmod +x kubectl
      sudo mv kubectl /usr/local/bin/
      return 0
}

function k8s::install_helm() {
      curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
      chmod +x kubectl
      sudo mv kubectl /usr/local/bin/
      return 0
}

# Create given namespace and set current context. Does not fail if exist already
function k8s::create_and_set_ns() {
    local ns="$1"
    [[ $(kubectl get ns | grep $ns) == "" ]] && kubectl create ns $ns
    kubectl config set-context --current --namespace=$ns
    return 0
}


# Delete ns and set current context to default
function k8s::delete_ns() {
    local ns="$1"
    kubectl delete namespace $ns --wait=false
    kubectl config set-context --current --namespace=default
    return 0
}

function k8s::force_delete_ns() {
    set +e
    local ns="$1"

    kubectl delete ns $ns --wait=false
    kubectl get ns $ns -o json | jq '.spec.finalizers=[]' > ns-without-finalizers.json

    kubectl proxy &
    sleep 1

    PID=$!
    curl -X PUT http://localhost:8001/api/v1/namespaces/$ns/finalize -H "Content-Type: application/json" --data-binary @ns-without-finalizers.json
    kill $PID

    kubectl delete ns $ns
    rm ns-without-finalizers.json
    set -e
}

# wait for resource to be online
function k8s::wait_resource_online() {
    local kind="$1"
    local name="$2"
    local retries="$3"

    printf "waiting for $kind $name to be online ."
    local i
    for i in $(seq 1 "$retries"); do
        if [ "$(kubectl get $kind $name -o=jsonpath='{.status.state}')" == "Online" ]; then
            printf $CHECKMARK
            echo ""
            return 0
        fi
        printf "."
        sleep 2
    done

    printf "timeout $CROSSMARK"
    echo ""
    return 1
}

# wait for resource to be ready in namespace
function k8s::wait_resource_ready_ns() {
    local kind="$1"
    local name="$2"
    local ns="$3"
    local retries="${4:-120}"

    local nsopt=""
    if [[ -n "$ns" ]]; then
        nsopt="-n ${ns}"
    fi
    printf "waiting for $kind $name to be ready ."
    local i
    for i in $(seq 1 "$retries"); do
        if [ "$(kubectl get ${nsopt} $kind $name -o=jsonpath='{.status.conditions[?(@.type=="Ready")].status}')" == "True" ]; then
            printf $CHECKMARK
            echo ""
            return 0
        fi
        printf "."
        sleep 2
    done

    printf "timeout $CROSSMARK"
    echo ""
    return 1
}

# wait for resource to be ready
function k8s::wait_resource_ready() {
    k8s::wait_resource_ready_ns $1 $2 "" ${3:-}
}


function k8s::wait_until_pods_running() {
    local ns="$1"
    echo -n "Waiting until all pods in namespace $ns are up"
    for i in {1..150}; do  # timeout after 5 minutes
        local pods="$(kubectl get pods --no-headers -n $ns 2>/dev/null)"
        # All pods must be running
        local not_running=$(echo "${pods}" | grep -v Running | grep -v Completed | wc -l)
        if [[ -n "${pods}" && ${not_running} -eq 0 ]]; then
            local all_ready=1
            while read pod ; do
                local status=(`echo -n ${pod} | cut -f2 -d' ' | tr '/' ' '`)
                # All containers must be ready
                [[ -z ${status[0]} ]] && all_ready=0 && break
                [[ -z ${status[1]} ]] && all_ready=0 && break
                [[ ${status[0]} -lt 1 ]] && all_ready=0 && break
                [[ ${status[1]} -lt 1 ]] && all_ready=0 && break
                [[ ${status[0]} -ne ${status[1]} ]] && all_ready=0 && break
            done <<< $(echo "${pods}" | grep -v Completed)
            if (( all_ready )); then
                printf "$CHECKMARK\n"
                echo -e "All pods are up:\n${pods}"
                return 0
            fi
        fi
        echo -n "."
        sleep 2
    done
    printf "$CROSSMARK"
    echo -e "ERROR: timeout waiting for pods to come up\n${pods}"
    return 1
}

function k8s::wait_log_contains() {
    local label="$1"
    local cname="$2"
    local str="$3"
    echo -n "monitoring logs in container ${cname} with label ${label}."
    for i in {1..150}; do
        local logs="$(kubectl logs -l${label} -c ${cname} --tail=100 2>/dev/null)"

        if [[ $logs == *${str}* ]]; then
            printf "found $CHECKMARK\n"
            return 0
        fi

        echo -n "."
        sleep 5

    done
    printf "$CROSSMARK"
    echo -e "ERROR: timeout waiting for pod log to contain \b${str}"
    return 1
}