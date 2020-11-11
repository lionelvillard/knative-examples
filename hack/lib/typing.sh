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


# Check if the number of arguments supplied is exactly correct.
function typing::check_arguments() {
  # We need at least one argument.
  if [[ $# -lt 1 ]]; then
    echo "Less than 1 argument received, exiting."
    exit 1
  fi

  # Deal with arguments
  expected_arguments=$1
  shift 1 # Removes the first argument.

  if [[ ${expected_arguments} -ne $# ]]; then
    return 1 # Return exit status 1.
  fi
}

# Checks if the argument is an integer.
function typing::check_integer() {
  # Input validation.
  if [[ $# -ne 1 ]]; then
    echo "Need exactly one argument, exiting."
    exit 1 # No validation done, exit script.
  fi

  # Check if the input is an integer.
  if [[ $1 =~ ^[[:digit:]]+$ ]]; then
    return 0 # Is an integer.
  else
    return 1 # Is not an integer.
  fi
}
