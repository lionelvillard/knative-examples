# Prerequites

- Knative 0.7
- DOCKER_USER set
- [stern](https://github.com/wercker/stern)
- [docker images](../../images)

# deploy

```sh
./deploy.sh
```

In one terminal, watch for `dumper` logs:

```sh
stern 'dumper' -c user-container
```

Send an event:

```sh
./sendevent.sh
```

Today: nothing happens. Expect `{"step":"last"}`
