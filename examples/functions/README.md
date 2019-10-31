# Knative Eventing Function

This example shows how to write and deploy Node.js [Knative Eventing Functions](https://github.com/knative/eventing/blob/master/docs/spec/interfaces.md#callable)
using [kone](https://github.com/ibm/kone) with a custom base image eliminating lots of boilerplace code.

## Quick start

Let's start with the identity function:

`function.js`:

```js
module.exports = event => event
```

The function:
- must reside in the file named `function.js`.
- must be exported.
- should take a CloudEvent as input. The CloudEvent follows the [JSON Event Format](https://github.com/cloudevents/spec/blob/v1.0/json-format.md#json-event-format-for-cloudevents---version-10).
-  can optionally return a CloudEvent. If it does the event is send back to the Knative Eventing system.

In order to deploy it, we need to tell `kone` what image name to give to the function and what base image to use:

`package.json`:

```json
{
  "name": "identity",
  "kone": {
    "defaultBaseImage": "docker.io/knativefunctions/function"
  }
}
```

The base image handles most of the boilerplace code for us:
- it loads our custom function stored in `function.js`
- it starts an HTTP server listening for POST request on port 8080
- and it converts HTTP requests to CloudEvents, back and forth.

Look at the [source code](../../src/function) for more information.

Let's create a Knative service using this function:

`config/identity-ksvc.yaml`:

```yaml
apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: identity
spec:
  template:
    spec:
      containers:
        - image: ../src/identity # points to the directory containing package.json
```

Then deploy it using `kone`, which takes care of making the docker image for the function and  deploys it to k8s:

```sh
kone apply -f config/identity-ksvc.yaml
```

Voila!