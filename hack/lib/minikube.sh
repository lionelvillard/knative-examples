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

# install minikube on linux
function minikube::install_linux() {
  u::header "installing minikube"
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
   && sudo install minikube-linux-amd64 /usr/local/bin/minikube

  mkdir -p $HOME/.kube $HOME/.minikube
  touch $KUBECONFIG

  return 0
}


# start minikube with given profile name
function minikube::start() {
  local profile=$1

  if [[ "$profile" == "" ]]; then
    u::fatal "usage minikube::start <profile>: missing argument"
  fi

  local vmdriver=none
  local sudo=sudo
  if [[ "$(uname)" == "Darwin" ]]; then
      vmdriver=hyperkit
      sudo=
  fi

  u::header "starting minikube"
  ${sudo} minikube start --memory=8192 --cpus=6 --kubernetes-version=v1.15.2 \
      --vm-driver=$vmdriver --disk-size=30g \
      -p $profile \
      --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"
  return 0
}