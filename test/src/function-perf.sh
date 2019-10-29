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
ROOT=$(dirname $BASH_SOURCE[0])/../..
source $ROOT/hack/lib/library.sh

function cleanup {
    if [[ -n $pid ]]; then
        kill $pid
        unset pid
    fi
}
trap cleanup EXIT

u::testsuite "Function"

cd $ROOT/src/function

node main.js &
pid=$!

sleep 1

printf "Sending 10000 events "
hey -n 10000 -m POST -d '{"message":"hello"}' http://localhost:8080

printf "Sending 1000 events 1MB body "
hey -n 1000 -m POST -D ../../test/src/payload-1MB.json http://localhost:8080

u::header "cleanup"