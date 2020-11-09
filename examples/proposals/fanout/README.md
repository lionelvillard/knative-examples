# Prerequites

- Knative 0.7
- DOCKER_USER set
- [stern](https://github.com/wercker/stern)

# deploy

```sh
./buildandpush.sh
kubectl apply -f config/
```

In one terminal, watch for receive-activity and record-assignment logs:

```sh
stern 'receive|record' -c user-container
```

Send an event:

```sh
./sendevent.sh
```

Observe the log:

```
+ record-assignment-bjzlc-deployment-74799b466f-z45xg › user-container
+ receive-activity-58l96-deployment-84c76b677f-rjmzx › user-container
record-assignment-bjzlc-deployment-74799b466f-z45xg user-container
record-assignment-bjzlc-deployment-74799b466f-z45xg user-container > @ start /app
record-assignment-bjzlc-deployment-74799b466f-z45xg user-container > node function.js
record-assignment-bjzlc-deployment-74799b466f-z45xg user-container
receive-activity-58l96-deployment-84c76b677f-rjmzx user-container
receive-activity-58l96-deployment-84c76b677f-rjmzx user-container > @ start /app
receive-activity-58l96-deployment-84c76b677f-rjmzx user-container > node function.js
receive-activity-58l96-deployment-84c76b677f-rjmzx user-container
record-assignment-bjzlc-deployment-74799b466f-z45xg user-container record-assignment
receive-activity-58l96-deployment-84c76b677f-rjmzx user-container receive-activity
```
