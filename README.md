# Knative Eventing Examples

This project contains a collection of Knative Eventing examples.

## Prerequisites

- [kind](https://kind.sigs.k8s.io)
- Optional [ko](https://github.com/google/ko)

## Examples

### Brokers

- **class**: MTChannelBasedBroker
  - **config**: In-Memory Channel
    - [Events from a specific source](./examples/broker/inmem/ceoverrides): Show
      how to use `CEOverrides` to receive events from a specific source.

### Sources

- APIServerSource
  - [Basic](./examples/sources/apiserver/sanity):
- PingSource
  - [Basic](./examples/sources/kafka/sanity): shows how to use PingSource to
    send events of various content types (json, xml) on a regular schedule to
    the event display service.
- KafkaSource:
  - [Basic configuration](./examples/sources/kafka/sanity): use KafkaSink to
    send events to two different Kafka topics and use KafkaSource to consume
    these events and forward them to the event display service.
  - [Autoscaling with KEDA](./examples/sources/kafka/keda): same example as
    above with KEDA autoscaling enabled
  - [IBM Cloud Event Streams](./examples/sources/kafka/eventstream): shows how
    to use KafkaSource to consume events coming from
    [IBM Cloud Event Streams](https://www.ibm.com/cloud/event-streams)

