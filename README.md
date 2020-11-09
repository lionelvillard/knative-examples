# Knative Eventing Examples

This project contains a collection of Knative Eventing examples.

## Prerequisites

- [kind](https://kind.sigs.k8s.io)
- Optional [ko](https://github.com/google/ko)

## Examples

### Brokers

- **class**: MTChannelBasedBroker
  - **config**: In-Memory Channel
    - [Events from a specific source](./examples/broker/inmem/ceoverrides/README.md):
      Show how to use `CEOverrides` to receive events from a specific source.

### Sources

- KafkaSource:
  - [Basic configuration](./examples/sources/kafka/sanity/README.md)
  - [Autoscaling with KEDA](./examples/sources/kafka/keda/README.md)
