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


## Random notes

The Sarama library creates 6 goroutines per partitions

```
100 @ 0x43a6a5 0x40676f 0x4063eb 0x185e9da 0x189c109 0x470141
#	0x185e9d9	github.com/Shopify/sarama.(*partitionConsumer).dispatcher+0x59	github.com/Shopify/sarama@v1.27.2/consumer.go:341
#	0x189c108	github.com/Shopify/sarama.withRecover+0x48			github.com/Shopify/sarama@v1.27.2/utils.go:43

100 @ 0x43a6a5 0x40676f 0x4063eb 0x185f64e 0x189c109 0x470141
#	0x185f64d	github.com/Shopify/sarama.(*partitionConsumer).responseFeeder+0x3ad	github.com/Shopify/sarama@v1.27.2/consumer.go:450
#	0x189c108	github.com/Shopify/sarama.withRecover+0x48				github.com/Shopify/sarama@v1.27.2/utils.go:43

100 @ 0x43a6a5 0x40676f 0x4063eb 0x189eb0e 0x470141
#	0x189eb0d	github.com/Shopify/sarama.newConsumerGroupSession.func1+0xad	github.com/Shopify/sarama@v1.27.2/consumer_group.go:589

100 @ 0x43a6a5 0x40676f 0x4063eb 0x189ecd1 0x470141
#	0x189ecd0	github.com/Shopify/sarama.(*consumerGroupSession).consume.func1+0xb0	github.com/Shopify/sarama@v1.27.2/consumer_group.go:675

100 @ 0x43a6a5 0x40676f 0x4063eb 0x189f02e 0x470141
#	0x189f02d	github.com/Shopify/sarama.newConsumerGroupClaim.func1+0xad	github.com/Shopify/sarama@v1.27.2/consumer_group.go:848

100 @ 0x43a6a5 0x40676f 0x4063eb 0x18f62e5 0x186708f 0x189ebc7 0x470141
#	0x18f62e4	knative.dev/eventing-kafka/pkg/common/consumer.(*SaramaConsumerHandler).ConsumeClaim+0x284	knative.dev/eventing-kafka/pkg/common/consumer/consumer_handler.go:75
#	0x186708e	github.com/Shopify/sarama.(*consumerGroupSession).consume+0x28e					github.com/Shopify/sarama@v1.27.2/consumer_group.go:690
#	0x189ebc6	github.com/Shopify/sarama.newConsumerGroupSession.func2+0x86					github.com/Shopify/sarama@v1.27.2/consumer_group.go:615

100 @ 0x43a6a5 0x44a80f 0x189edbe 0x470141
#	0x189edbd	github.com/Shopify/sarama.(*consumerGroupSession).consume.func2+0xbd	github.com/Shopify/sarama@v1.27.2/consumer_group.go:682
```


