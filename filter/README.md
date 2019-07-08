# Prerequites

- Knative HEAD
- DOCKER_USER set
- [stern](https://github.com/wercker/stern)

# deploy

```sh
./buildandpush.sh
kubectl apply -f config/
```

In one terminal, watch for send-message and wait-assignment logs:

```sh
stern send-message -c user-container
```

Send true event:

```sh
./sendevent.true.sh
```

Observe the log:

```
+ send-message-jgrfq-deployment-7d7b89f778-ln4sr › user-container
send-message-jgrfq-deployment-7d7b89f778-ln4sr user-container
send-message-jgrfq-deployment-7d7b89f778-ln4sr user-container > @ start /app
send-message-jgrfq-deployment-7d7b89f778-ln4sr user-container > node main.js
send-message-jgrfq-deployment-7d7b89f778-ln4sr user-container
send-message-jgrfq-deployment-7d7b89f778-ln4sr user-container assignment received (john)
```

Send false event:

```sh
./sendevent.false.sh
```

Observe the log:

```
+ wait-assignment-x76bl-deployment-77b47d65bf-kkstm › user-container
wait-assignment-x76bl-deployment-77b47d65bf-kkstm user-container
wait-assignment-x76bl-deployment-77b47d65bf-kkstm user-container > @ start /app
wait-assignment-x76bl-deployment-77b47d65bf-kkstm user-container > node main.js
wait-assignment-x76bl-deployment-77b47d65bf-kkstm user-container
wait-assignment-x76bl-deployment-77b47d65bf-kkstm user-container wait for assigment
```

