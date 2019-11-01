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

u::testsuite "Function - single"

# setting up directory structure

single=$(mktemp -d)
params=$(mktemp -d)
dispatch=$(mktemp -d)

cp $ROOT/src/function/* $single
cp $ROOT/src/function/* $params
cp $ROOT/src/function/* $dispatch

cp $ROOT/test/src/params-test.js $params/function.js
cp $ROOT/test/src/dispatch-test.js $dispatch/function.js

# SINGLE TESTS

cd $single

node main.js &
pid=$!

sleep 1

printf "should return 404 (bad method)"
o1=$(curl -sw "%{response_code}" localhost:8080)
if [[ $o1 != "404" ]]; then
    u::fatal "expected 404 http code"
fi
printf "$CHECKMARK\n"

printf "should return event "
o2=$(curl -s localhost:8080 -d '{"message":"hello"}')
if [[ "$o2" != '{"message":"hello"}' ]]; then
    u::fatal "unexpected response $o2"
fi
printf "$CHECKMARK\n"

printf "Should return empty body "
o3=$(curl -s localhost:8080 -X POST)
if [[ "$o3" != '' ]]; then
   u::fatal "unexpected response $o3"
fi
printf "$CHECKMARK\n"

# Unicode
printf "data with unicode "
o4=$(curl -s localhost:8080 -d '{"message":"†˙ˆß ˆß çøø¬"}')
if [[ "$o4" != '{"message":"†˙ˆß ˆß çøø¬"}' ]]; then
    u::fatal "unexpected response $o4"
fi
printf "$CHECKMARK\n"

printf "Invalid JSON data "
o=$(curl -s localhost:8080 -d '{"message":"missing bracket}')
if  [[ "$o" != 'invalid JSON: SyntaxError: Unexpected end of JSON input' ]]; then
    u::fatal "unexpected response $o"
fi
printf "$CHECKMARK\n"

kill $pid

u::testsuite "Function - params"

cd $params

node main.js &
pid=$!

sleep 1

printf "should replace event data to be world"
resp=$(curl -s localhost:8080?data=world -d '{}')
if [[ $resp != '"world"' ]]; then
     u::fatal "unexpected response $resp"
fi
printf "$CHECKMARK\n"

printf "should not replace anything"
resp=$(curl -s localhost:8080? -d '{}')
if [[ $resp != '{}' ]]; then
     u::fatal "unexpected response $resp"
fi
printf "$CHECKMARK\n"


kill $pid

u::testsuite "Function - dispatch"

cd $dispatch

node main.js &
pid=$!

sleep 1

printf "dispatch - should return 404 (root) "
o=$(curl -X POST -sw "%{response_code}" localhost:8080)
if  [[ $o != "404" ]]; then
    u::fatal "expected 404 http code"
fi
printf "$CHECKMARK\n"

printf "dispatch - should return 404 (invalid function name) "
o=$(curl -X POST -sw "%{response_code}" localhost:8080/invalid/path)
if  [[ $o != "404" ]]; then
    u::fatal "expected 404 http code"
fi
printf "$CHECKMARK\n"

printf "dispatch - should evaluate content filter  "
o=$(curl -s localhost:8080/content-filter -d '{"filter":true}')
if  [[ $o != "" ]]; then
    u::fatal "expected empty event"
fi
printf "$CHECKMARK\n"

printf "dispatch - should evaluate attribute type filter  "
o=$(curl -s localhost:8080/attr-type-filter -H 'ce-type: my.event.type' -d '{"message":"hello"}')
if  [[ $o != '{"message":"hello"}' ]]; then
    u::fatal "unexpected response $o"
fi
printf "$CHECKMARK\n"


u::header "cleanup"