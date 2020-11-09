#!/usr/bin/env bash

kubectl exec -n kafka my-cluster-kafka-0 -- bin/kafka-consumer-groups.sh --bootstrap-server my-cluster-kafka-bootstrap.kafka:9092 --describe  --all-groups
