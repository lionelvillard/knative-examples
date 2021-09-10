docker run -d --rm -p 9000:9000 \
    -e KAFKA_BROKERCONNECT=broker-0-ys5snp917xwwz1yw.kafka.svc09.us-south.eventstreams.cloud.ibm.com:9093 \
    -e KAFKA_PROPERTIES="$(cat kafka.cfg | base64)" \
    obsidiandynamics/kafdrop
