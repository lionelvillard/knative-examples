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

rm -f config/products-kafkasource.yaml
rm -f config/event-sender-products.yaml
rm -f config/products-topic.yaml
rm -f config/products-kafkasink.yaml
touch config/products-kafkasource.yaml
touch config/event-sender-products.yaml
touch config/products-topic.yaml
touch config/products-kafkasink.yaml

for (( i = 0; i < 100; ++i )); do
    cat templates/products-kafkasource.yaml | sed "s/products/products-${i}/g" >> config/products-kafkasource.yaml
    echo "---" >> config/products-kafkasource.yaml
    cat templates/event-sender-products.yaml | sed "s/products/products-${i}/g" >> config/event-sender-products.yaml
    echo "---" >> config/event-sender-products.yaml
    cat templates/products-topic.yaml | sed "s/products/products-${i}/g" >> config/products-topic.yaml
    echo "---" >> config/products-topic.yaml
    cat templates/products-kafkasink.yaml| sed "s/products/products-${i}/g" >> config/products-kafkasink.yaml
    echo "---" >> config/products-kafkasink.yaml
done
