# API Server Source Example

This folder contains an example using the Knative Eventing
[API Server source](https://knative.dev/docs/eventing/sources/apiserversource/).

See [Prerequisites](../../../README.md#prerequisites).

To run:

- `./0-start-kind.sh`
- `./1-setup-cluster.sh`
- `./3-deploy.sh`

## Verifying

```sh
kubectl -n example-apiserversource-sanity run busybox --image=busybox --restart=Never -- ls
kubectl -n example-apiserversource-sanity delete pod busybox
```

Then look at the logs:

```sh
kubectl -n example-apiserversource-sanity logs -l app=event-display --tail=100
```
