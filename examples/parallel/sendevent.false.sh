#!/usr/bin/env bash

TARGET=$(kubectl get parallels.messaging.knative.dev check-assignment -o=jsonpath='{.status.address.url}')

kubectl run sendevent -it --image=villardl/sendevent-2e4a9de951897fc25b3c07443d373b90 --generator=run-pod/v1 -- \
  -sink $TARGET \
  -event-type dev.knative.foo.bar \
  -data '{ "assigned": false }'



