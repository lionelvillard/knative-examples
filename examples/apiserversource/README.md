# API Server Source Example

This folder contains an example using the Knative Eventing [API Server source](https://github.com/knative/eventing/blob/master/pkg/apis/sources/v1alpha1/apiserver_types.go).

See [Prerequisites](../../README.md#prerequisites).

This example creates an API server source object watching for Knative serving `revision` objects:

```yaml
apiVersion: sources.eventing.knative.dev/v1alpha1
kind: ApiServerSource
metadata:
  name: revision
  namespace: apiserversource-example
spec:
  mode: Ref
  resources:
  - apiVersion: serving.knative.dev/v1alpha1
    kind: Revision
  serviceAccountName: apiserversource-example
  sink:
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    name: event-display
```

`mode` can either be `Ref` or `Resource`. In the `Ref` mode, only the object reference is sent in the CloudEvents payload. In the `Resource` mode, the entire object is included.

`resources` specifies the list of resources to watch for. Here we are just watching for revisions.

The `serviceAccountName` points to the service account allowing `get`, `watch` and `list` on all the resources we are interested in, in this particular case revisions. See [100-apiserversource-example-sa.yaml](./config/100-apiserversource-example-sa.yaml)

Finally, `sink` specifies where to send events.

## Deploying

```sh
kubectl apply -f config/
```

## Verifying

Make sure the source is ready:

```sh
$ kubectl get apiserversources.sources.eventing.knative.dev revision
NAME       AGE
revision   7m23s
```

## Testing

Create a dummy Knative service:

```sh
kubectl apply -f dummy-ksvc.yaml
```

Then look at the logs (trimmed for readability):

```sh
$ stern event -c user-container
 ☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.3
   type: dev.knative.apiserver.ref.delete
   source: https://10.96.0.1:443
   subject: /apis/serving.knative.dev/v1alpha1/namespaces/apiserversource-example/revisions/dummy-jpqgr
   id: 73be9839-824e-43ea-9531-4a8d0ac9324c
   time: 2019-10-28T19:08:15.857422Z
 Data,
   {"kind":"Revision","namespace":"apiserversource-example","name":"dummy-jpqgr","apiVersion":"serving.knative.dev/v1alpha1"}
 ☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.3
   type: dev.knative.apiserver.ref.add
   source: https://10.96.0.1:443
   subject: /apis/serving.knative.dev/v1alpha1/namespaces/apiserversource-example/revisions/dummy-p2s6x
   id: 79f156a2-bb0b-4419-a185-28e3c58e70fe
   time: 2019-10-28T19:08:22.2311337Z
 Data,
   {"kind":"Revision","namespace":"apiserversource-example","name":"dummy-p2s6x","apiVersion":"serving.knative.dev/v1alpha1"}
 ☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.3
   type: dev.knative.apiserver.ref.update
   source: https://10.96.0.1:443
   subject: /apis/serving.knative.dev/v1alpha1/namespaces/apiserversource-example/revisions/dummy-p2s6x
   id: c9d32465-ca27-4640-ac95-5577e3db3384
   time: 2019-10-28T19:08:22.6736183Z
 Data,
   {"kind":"Revision","namespace":"apiserversource-example","name":"dummy-p2s6x","apiVersion":"serving.knative.dev/v1alpha1"}
 ☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.3
   type: dev.knative.apiserver.ref.update
   source: https://10.96.0.1:443
   subject: /apis/serving.knative.dev/v1alpha1/namespaces/apiserversource-example/revisions/dummy-p2s6x
   id: dc920e80-8fd0-4493-993c-2c6eb1f46fd6
   time: 2019-10-28T19:08:23.103795Z
 Data,
   {"kind":"Revision","namespace":"apiserversource-example","name":"dummy-p2s6x","apiVersion":"serving.knative.dev/v1alpha1"}
 ☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.3
   type: dev.knative.apiserver.ref.update
   source: https://10.96.0.1:443
   subject: /apis/serving.knative.dev/v1alpha1/namespaces/apiserversource-example/revisions/dummy-p2s6x
   id: 0eee99e3-a97e-485c-a538-da50a9501172
   time: 2019-10-28T19:08:25.941822Z
 Data,
   {"kind":"Revision","namespace":"apiserversource-example","name":"dummy-p2s6x","apiVersion":"serving.knative.dev/v1alpha1"}
 ☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.3
   type: dev.knative.apiserver.ref.update
   source: https://10.96.0.1:443
   subject: /apis/serving.knative.dev/v1alpha1/namespaces/apiserversource-example/revisions/dummy-p2s6x
   id: be22c16a-73dd-4b64-bd9b-12c6c078a480
   time: 2019-10-28T19:08:26.0153044Z
 Data,
   {"kind":"Revision","namespace":"apiserversource-example","name":"dummy-p2s6x","apiVersion":"serving.knative.dev/v1alpha1"}
 ☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.3
   type: dev.knative.apiserver.ref.update
   source: https://10.96.0.1:443
   subject: /apis/serving.knative.dev/v1alpha1/namespaces/apiserversource-example/revisions/dummy-p2s6x
   id: 3c763b19-f10f-4781-b0be-c9676e5507ca
   time: 2019-10-28T19:08:26.1376721Z
 Data,
   {"kind":"Revision","namespace":"apiserversource-example","name":"dummy-p2s6x","apiVersion":"serving.knative.dev/v1alpha1"}
```
