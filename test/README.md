# Testing

## Environments

End-to-end tests run against a [kind](https://github.com/kubernetes-sigs/kind) cluster. To create it, run:

```sh
hack/setup-knative-kind <knative-serving-version> <knative-eventing-version>
```

where `knative-xx-version` must have 3 version digits, eg. `0.8.0`, or [`nightly`](https://testgrid.knative.dev/eventing#nightly).

The istio ingress is exposed locally on port 8080.


## Running all 2e2 tests

Just do:

```sh
./test.e2e.sh
```

## Running one test

Make sure all Node.js depencendies are installed:

```sh
hack/npm-install.sh
```

Then you can run one e2e test directly:

```sh
test/sequence.sh # run sequence tests
test/parallel.sh # run parallel tests
```




