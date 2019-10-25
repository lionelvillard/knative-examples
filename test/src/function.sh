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

# Check Bad Method
printf "Should return 404 "
o1=$(curl -sw "%{response_code}" localhost:8080)
if  [[ $o1 != "404" ]]; then
    u::fatal "expected 404 http code"
fi
printf "$CHECKMARK\n"

# Check identity
printf "Should return event "
o2=$(curl -s localhost:8080 -d '{"message":"hello"}')
if  [[ "$o2" != '{"message":"hello"}' ]]; then
    u::fatal 'expected {"message":"hello"}, got $o2'
fi
printf "$CHECKMARK\n"

# Empty data
printf "Should return empty body "
o3=$(curl -s localhost:8080 -X POST)
if  [[ "$o3" != '' ]]; then
    u::fatal 'expected empty body, got'$o3
fi
printf "$CHECKMARK\n"

u::header "cleanup"