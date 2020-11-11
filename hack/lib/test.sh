
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

COLOR_RESET="\e[00m"
COLOR_GREEN="\e[1;32m"
COLOR_RED="\e[00;31m"

BOLD=$(tput bold)
NORMAL=$(tput sgr0)

CHECKMARK="${COLOR_GREEN}✔${COLOR_RESET}"
CROSSMARK="${COLOR_RED}✗${COLOR_RESET}"

# print header in bold
function u::header() {
    echo ""
    echo ${BOLD}${1}${NORMAL}
}

function u::abs_path() {
    local path="$1"
    echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
}

# print error in red and exit
function test::fatal() {
    echo ""
    printf "${COLOR_RED}${1}${NORMAL}\n"
    exit 1
}

test_logfile=

# print test suite description and initialize log
function test::suite() {
    typing::check_arguments 1 "$@"

    test_logfile=$(mktemp -t log.XXX)
    echo log file is $test_logfile >&2

    u::header "$1"
    u::header "${BOLD}====${NORMAL}"

}

# start a test case
function test::case() {
    typing::check_arguments 1 "$@"
    printf " ${BOLD}${1}${NORMAL} "
    test::log "== starting test case $1"
}

# Mark test case as failed and exit
function test::fail() {
    printf "${CROSSMARK}\n"
    test::log "== test case failed"
    exit 1
}

# Mark test case as suceeded
function test::pass() {
    printf "${CHECKMARK}\n"
    test::log "== test case pass"
}

# log message
function test::log() {
    typing::check_arguments 1 "$@"

    if [[ -z "$test_logfile" ]]; then
        echo "$1" >&2
    else
        echo "$1" >> $test_logfile
    fi
}
