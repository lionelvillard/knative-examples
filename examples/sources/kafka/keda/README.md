# KafkaSource Autoscaling with KEDA

Topology:

```
event-sender -> kafka-sink -> Kafka <- kafka-source -> event-receiver
```

To run:

- `./1-setup-cluster.sh`
- `./3-deploy.sh`

Observe events being received at a rate of 10 events/s

```
kubectl logs -lapp=event-display -f
```

Observer the Kafka lag:

```
kubectl exec -n kafka my-cluster-kafka-0 -- \
 bin/kafka-consumer-groups.sh \
 --bootstrap-server my-cluster-kafka-bootstrap.kafka:9092 \
 --describe --group knative-group
```

Warning: need Knative Kafka master

```
GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID                                 HOST            CLIENT-ID
knative-group   products        8          1241            1242            1               sarama-265a933b-d5be-4a4e-94bd-fbd99af27815 /10.244.0.37    sarama
knative-group   products        2          1303            1303            0               sarama-265a933b-d5be-4a4e-94bd-fbd99af27815 /10.244.0.37    sarama
knative-group   products        3          1313            1314            1               sarama-265a933b-d5be-4a4e-94bd-fbd99af27815 /10.244.0.37    sarama
knative-group   products        5          1221            1223            2               sarama-265a933b-d5be-4a4e-94bd-fbd99af27815 /10.244.0.37    sarama
knative-group   products        4          1230            1231            1               sarama-265a933b-d5be-4a4e-94bd-fbd99af27815 /10.244.0.37    sarama
knative-group   products        0          1290            1292            2               sarama-265a933b-d5be-4a4e-94bd-fbd99af27815 /10.244.0.37    sarama
knative-group   products        7          1246            1246            0               sarama-265a933b-d5be-4a4e-94bd-fbd99af27815 /10.244.0.37    sarama
knative-group   products        1          1266            1266            0               sarama-265a933b-d5be-4a4e-94bd-fbd99af27815 /10.244.0.37    sarama
knative-group   products        9          1237            1238            1               sarama-265a933b-d5be-4a4e-94bd-fbd99af27815 /10.244.0.37    sarama
knative-group   products        6          1255            1256            1               sarama-265a933b-d5be-4a4e-94bd-fbd99af27815 /10.244.0.37    sarama
```

Notice there is only one host and LAG is very small (< 2)

Run a job sending events at a rate of 50 events/s

```
kubectl apply -f config-2
```
