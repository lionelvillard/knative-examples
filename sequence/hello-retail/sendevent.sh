#!/usr/bin/env bash

CHANNEL_HOSTNAME=$(kubectl get sequences.messaging.knative.dev acquire-photo -o=jsonpath='{.status.address.hostname}')

kubectl exec shell -- curl $CHANNEL_HOSTNAME \
  -X POST \
  -H 'content-type: application/json' \
  -H "ce-specversion: 0.3" \
  -H "ce-type: com.hello-retail.product.created" \
  -H "ce-id: 1" \
  -H "ce-source: localhost" \
  -d '{ "data": { "brand": "POLO RALPH LAUREN", "name": "Polo Ralph Lauren 3-Pack Socks", "category": "Socks for Men" } }'