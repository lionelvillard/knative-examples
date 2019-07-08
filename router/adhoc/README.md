# Prerequites

- Knative HEAD + [this PR](https://github.com/knative/eventing/pull/1436)
- DOCKER_USER set.
- [kapp](https://get-kapp.io/)

# deploy


```sh
./buildandpush.sh
kubectl apply -f config/
```

send event:

```sh
./sendevent.sh
```

observe the dispatcher log:

```sh
stern -n knative-eventing imc -c dispatcher
```