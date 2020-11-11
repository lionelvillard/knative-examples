
#!/bin/bash
#
# Copyright 2017-2018 IBM Corporation
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
#
 #!/usr/bin/env bash

# Copyright 2020 IBM Corporation
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

# returns the number of recorded events
function event::count() {
    local name="$1"
    local ns="${2:-}"

    if [[ -z "$ns" ]]; then
      ns=$(k8s::get_current_ns)
    fi

    k8s::curl $ns $name db /events?summary=count
}


# reset the database
function event::reset() {
    local name="$1"
    local ns="${2:-}"

    if [[ -z "$ns" ]]; then
      ns=$(k8s::get_current_ns)
    fi

    k8s::curl $ns $name db /events DELETE
}
