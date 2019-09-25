#!/usr/bin/env bash

TARGET=$(kubectl get parallels.messaging.knative.dev check-assignment -o=jsonpath='{.status.address.url}')

kubectl run sendevent --rm --image=villardl/sendevent --generator=run-pod/v1 -- \
  -sink $TARGET \
  -event-type dev.knative.foo.bar \
  -data '{ "assigned": true }'

