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

ROOT=$(dirname $BASH_SOURCE[0])/../../../..
source $ROOT/hack/lib/library.sh

NS=sources-kafka-sanity

k8s::wait_until_pods_running "$NS"

test::suite "testing KafkaSource"

test::case "check event-display is receiving events"

    count=$(event::count event-display)

    if [[ "$count" -le 0 ]]; then
        test::fail
    fi

test::pass

test::case "check when killing the receive adapter pods, no events are lost"

test::pass

test::case "check event-display does not receive events after stopping the producers"

    kubectl delete jobs.batch --all >> /dev/null

    sleep 2 # wait for events to drain

    event::reset event-display

    sleep 5 # wait a bit, just to be sure

    count=$(event::count event-display)

    if [[ $count -gt 0 ]]; then
        test::fail
    fi

test::pass


