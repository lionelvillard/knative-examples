# KafkaSource - Basic example

Topology:

```
event-sender -> kafka-sink -> Kafka <- kafka-source -> event-display
```

Repeated twice with `fruits` and `products` topics.

To run:

- `./0-start-kind.sh`
- `./1-setup-cluster.sh`
- `./3-deploy.sh`
- `./8-cleanup.sh`
