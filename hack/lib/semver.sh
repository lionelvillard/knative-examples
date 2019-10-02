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

function semver::lt() {
    local left="$1"
    local right="$2"

    local major_left=${left%%.*}
    local major_right=${right%%.*}

    if [[ $major_left -lt $major_right ]]; then
        echo "true"
        return 0
    fi

    local rest_left=${left#*.}
    local rest_right=${right#*.}

    local minor_left=${rest_left%%.*}
    local minor_right=${rest_right%%.*}
    if [[ $minor_left -lt $minor_right ]]; then
        echo "true"
        return 0
    fi

    patch_left=${rest_left#*.}
    patch_right=${rest_right#*.}

    if [[ $patch_left -lt $patch_right ]]; then
        echo "true"
        return 0
    fi

    echo "" # false
}


function semver::gte() {
    local left="$1"
    local right="$2"

    if [[ -z "${left}" || "${left}" == "nightly" || "${left}" == "${right}" ]]; then
        echo "true"
        return 0
    fi

    if [[ $(semver::lt "${left}" "${right}") ]]; then
        echo ""
        return 0
    fi

    echo "true"
    return 0
}