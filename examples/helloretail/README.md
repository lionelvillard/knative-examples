# Hello Retail with Knative

Hello, Retail! is a [Nordstrom Technology open-source project](https://github.com/Nordstrom/hello-retail). Hello, Retail! is a 100% serverless, event-driven framework and functional proof-of-concept showcasing a central unified log approach as applied to the retail problem space. All code and patterns are intended to be re-usable for scalable applications large and small.

This example focuses on [Product Photos](https://github.com/Nordstrom/hello-retail/tree/master/product-photos) which is a workflow
aiming at ensuring a photo is taken for a new product.

Showcase [Sequence](https://knative.dev/development/eventing/sequence/), [Parallel](https://knative.dev/development/eventing/parallel/) and [Knative Eventing Function](../functions)

## Prerequites

- A Kubernetes cluster with [Knative Serving and Eventing](https://knative.dev) 0.10+.
- [kone](https://github.com/ibm/kone) installed and configured.
- [stern](https://github.com/wercker/stern) (optional)

To run this example locally, create a [kind](../../README.md#kind) cluster.

## Deployment steps

Make sure your current working directory is `examples/helloretail`.

### Creating k8s namespace

```sh
kubectl create namespace hello-retail
```

### Deploying the application

```sh
kone apply -f config
```

## Verifying

Verify that all services are ready:

```sh
kubectl get ksvc
NAME            URL                                             LATESTCREATED         LATESTREADY           READY   REASON
assign          http://assign.hello-retail.example.com          assign-d7vhz          assign-d7vhz          True
check-assign    http://check-assign.hello-retail.example.com    check-assign-jmrhz    check-assign-jmrhz    True
event-display   http://event-display.hello-retail.example.com   event-display-4v8k2   event-display-4v8k2   True
wait            http://wait.hello-retail.example.com            wait-9hxsw            wait-9hxsw            True
```

## Testing

In one terminal, run:

```sh
stern -n helloretail -c user event
```

Then in another terminal, invoke `add-product`:

```sh
./add-product.sh
```

You should see (trimmed for readability):

```
stern event -c user
+ › user-container
 ☁️  cloudevents.Event
 Validation: valid
 Context Attributes,
   specversion: 0.3
   type: asource
   source: asource
   id: 4579874
   time: 2019-11-01T18:22:26.612266086Z
   datacontenttype: application/json
 Extensions,
   knativehistory: assign-photographer-kn-sequence-0-kn-channel.hello-retail.svc.cluster.local; check-assignment-kn-parallel-kn-channel.hello-retail.svc.cluster.local; check-assignment-kn-parallel-1-kn-channel.hello-retail.svc.cluster.local
   traceparent: 00-99aed4828d2125005d5bcc404e658d98-9441d8e6a351c021-00
 Data,
   {
     "id": 4579874,
     "brand": "POLO RALPH LAUREN",
     "name": "Polo Ralph Lauren 3-Pack Socks",
     "description": "PAGE:/s/polo-ralph-lauren-3-pack-socks/4579874",
     "category": "Socks for Men",
     "photographers": [
       "mike430"
     ],
     "photographer": {
       "name": "Mike",
       "id": "mike430",
       "assigned": false
     },
     "assigned": true,
     "assignmentComplete": false
   }
```

## Cleanup

Delete the `hello-retail` namespace:

```sh
kubectl delete namespace hello-retail
```



