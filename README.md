# Knative Eventing Examples

This project contains various Knative Eventing examples.

## Prerequisites

A Kubernetes cluster with Knative installed. Each example has its own Knative version requirement

To install Knative in minikube, run:

```sh
bin/setup-knative-minikube.sh <knative-version>
```

`knative-version` must have 3 version digits, eg `0.8.0`

This creates a minikube VM with the profile named `knative-<version>` and install Knative in it.