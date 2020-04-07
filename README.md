# Knative Eventing Examples
[![Build Status](https://travis-ci.org/lionelvillard/knative-examples.svg?branch=master)](https://travis-ci.org/lionelvillard/knative-examples)

This project contains various Knative Eventing examples.

## Prerequisites

- A Kubernetes cluster with Knative installed. For local testing I recommend [kind](#kind).
- [kone](https://github.com/ibm/kone) installed and configured. `kone` is like `ko` for Node.js (instead of go).
- [stern](https://github.com/wercker/stern) for log tailing.

### Kind

To create a [kind](https://github.com/kubernetes-sigs/kind) cluster and install Knative, run:

```sh
bin/setup-knative-kind.sh <knative-serving-version> <knative-eventing-version>
```

For instance:

```sh
bin/setup-knative-kind.sh 0.10.0 0.10.0
```

This creates a kind cluster named `knative-s0.10.0-e0.10.0` and installs Knative (no monitoring).

### Minikube

To install Knative in minikube, run:

```sh
bin/setup-knative-minikube.sh <knative-serving-version> <knative-eventing-version>
```

`knative-version` must have 3 version digits, eg `0.8.0`

This creates a minikube VM with the profile named `k-s<knative-serving-version>-e<knative-eventing-version>` and installs Knative.

### Add-ons (optional)

To install add-ons operators

```sh
bin/setup-addon-operators.sh
```

## Examples

### Full Applications

- [Cloudant Data Processing with Knative](./examples/data-processing): showcase the CouchDB Event Source
- [Hello Retail](./examples/helloretail): showcase Sequence, Parallel and eventing functions

### Composition

- [Simple Sequence](./examples/sequence)
- [Simple Parallel](./examples/parallel)

### Event Source

- [API Server Source Examples](./examples/apiserversource)
- [CronJob Targeting "Plain" Kubernetes Service](./examples/k8sservice)
- [CouchDB Event source with IBM Cloudant](examples/sources/couchdb/cloudant)

### Misc.

- [Node.js Knative Eventing Functions](https://github.com/lionelvillard/knative-functions/tree/master/proxies/nodejs), the easy way.