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

GITHUB_ENPOINT="https://api.github.com"

function github::create_release() {
  local oauthtoken="$1"
  local ownerrepo="$2" # owner/repo
  local tag_name="$3" # vx.x.x

  curl -s -H "Authorization: token ${oauthtoken}" \
    -H "User-Agent: curl" $GITHUB_ENPOINT/repos/${ownerrepo}/releases \
    -d '{"tag_name": "'${tag_name}'", "name": "'${tag_name}'"}'
}

function github::get_release_id() {
  local oauthtoken="$1"
  local ownerrepo="$2" # owner/repo
  local tag_name="$3" # vx.x.x

  rel=$(curl -s -H "Authorization: token ${oauthtoken}" \
    -H "User-Agent: curl" $GITHUB_ENPOINT/repos/${ownerrepo}/releases/tags/${tag_name})
  echo $rel | jq -r ".id"
}

function github::upload_asset() {
  local oauthtoken="$1"
  local ownerrepo="$2" # owner/repo
  local tag_name="$3"
  local file="$4"

  local id=$(github::get_release_id "$oauthtoken" "$ownerrepo" "$tag_name")

  curl -s -H "Authorization: token ${oauthtoken}" \
    -H "Content-Type: $(file -b --mime-type ${file})" \
    --data-binary @${file} "https://uploads.github.com/repos/${ownerrepo}/releases/${id}/assets?name=$(basename $file)"
}