# Knative Eventing Examples
[![Build Status](https://travis-ci.org/lionelvillard/knative-examples.svg?branch=master)](https://travis-ci.org/lionelvillard/knative-examples)

This project contains various Knative Eventing examples.

## Prerequisites

A Kubernetes cluster with Knative installed. Each example has its own Knative version requirement

### Minikube

To install Knative in minikube, run:

```sh
bin/setup-knative-minikube.sh <knative-serving-version> <knative-eventing-version>
```

`knative-version` must have 3 version digits, eg `0.8.0`

This creates a minikube VM with the profile named `k-s<knative-serving-version>-e<knative-eventing-version>` and installs Knative.

### Kind

To install Knative in [kind](https://github.com/kubernetes-sigs/kind), run:

```sh
bin/setup-knative-kind.sh <knative-serving-version> <knative-eventing-version>
```

This creates a kind cluster named `knative-s<knative-serving-version>-e<knative-eventing-version>` and installs Knative.

### Add-ons (optional)

To install add-ons operators

```sh
bin/setup-addon-operatirs.sh
```

## Examples

### Full Applications

- [Cloudant Data Processing with Knative](./examples/data-processing/README.md)

### Composition

- [Simple Sequence](./examples/sequence/README.md)
- [Simple Parallel](./examples/parallel/README.md)

### Event Source

- CouchDB using [IBM Cloudant](./examples/couchdb/cloudand/README.md)
