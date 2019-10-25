# Cloudant Data Processing with Knative

This example shows how serverless, event-driven architectures can be used to execute code in response to database change events from Cloudant, thus extracting scalable and efficient analytics from both technologies. It also shows how Kubernetes operators are used to configure services and bindings.

This application shows you two Knative functions (written in JavaScript) that write and read text and image data to Cloudant, a hosted Apache CouchDB service. The scenario demonstrates how Knative functions can work with data services and execute logic in response to database changes.

One function connects to Cloudant and inserts text and binary data as an attachment. The function configuration mounts the Cloudant credential produced by the [IBM cloud operator](https://github.com/IBM/cloud-operators/).

A second function responds to the changes that were inserted into Cloudant by the first function. Instead of being manually invoked, the developer defines a Knative CouchDB source listening to Cloudant changes.

This example is the Knative version of [Cloudant data processing with IBM Cloud Functions](https://github.com/IBM/ibm-cloud-functions-data-processing-cloudant) example.

## Prerequites

- A Kubernetes cluster with
    - [Knative Serving and Eventing](https://knative.dev) 0.10+
    - [IBM Cloud Operator](https://github.com/IBM/cloud-operators) (optional)
- [Kone](https://github.com/ibm/kone) installed and configured.
- [stern](https://github.com/wercker/stern) (optional)
- The IBM Cloud CLI (optional)


## Deployment steps

### Creating k8s namespace

```sh
kubectl create namespace knative-dataprocessing
```

### Provisioning Cloudant

#### With IBM Cloud Operator

1. Configure the IBM Cloud Operator by creating a secret with your [API key](https://cloud.ibm.com/iam/apikeys) and your region (eg. `us-south`):

```sh
kubectl create secret generic seed-secret -n knative-dataprocessing \
   --from-literal=api-key=${APIKEY} \
   --from-literal=region=${REGION}
kubectl label secret seed-secret -n knative-dataprocessing seed.ibm.com/ibmcloud-token=apikey
```

1. Deploy the IBM Cloud Operator objects:

```sh
kubectl apply -n knative-dataprocessing -f config/operator
```

#### With the ibmcloud CLI

Go to [IBM Cloudant Documentation](https://cloud.ibm.com/docs/services/Cloudant?topic=cloudant-getting-started) to learn how to create service credential for your service instance.

From the service credentials, get the `url` value and do:

```sh
kubectl create secret generic cloudant -n knative-dataprocessing \
  --from-literal=url=${CLOUDANT_URL}
```

### Deploying the application

```sh
kone apply -n knative-dataprocessing -f config
```

## Verifying

Verify that all services are ready:


```sh
kubectl get -n knative-dataprocessing services.serving.knative.dev
NAME                  URL                                                                                              LATESTCREATED               LATESTREADY                 READY   REASON
write-from-cloudant   http://write-from-cloudant.knative-dataprocessing.kube-dev.us-south.containers.appdomain.cloud   write-from-cloudant-vp7pg   write-from-cloudant-vp7pg   True
write-to-cloudant     http://write-to-cloudant.knative-dataprocessing.kube-dev.us-south.containers.appdomain.cloud     write-to-cloudant-wswbx     write-to-cloudant-wswbx     True
```

Optionally verify the services and bindings are online:

```sh
kubectl get -n knative-dataprocessing services.ibmcloud.ibm.com cloudant
NAME       STATUS   AGE
cloudant   Online   5m3s
```

```sh
kubectl get -n knative-dataprocessing bindings.ibmcloud.ibm.com
NAME       STATUS   AGE
cloudant   Online   5m1s
```

## Testing

In one terminal, run:

```sh
stern -n knative-dataprocessing write
```

Then in another terminal, invoke `write-to-cloudant`:

```sh
./invoke-write-to-cloudant.sh
```

You should see:


```
+ write-to-cloudant-7xpjg-deployment-54f9c8b4d-hpkw8 › user-container
write-to-cloudant-7xpjg-deployment-54f9c8b4d-hpkw8 user-container Success with file insert.
+ write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 › user-container
write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 user-container [write-from-cloudant.main] Writing database changes to console
write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 user-container {
write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 user-container   id: '4-g1AAAAZJeJy11M1NwzAUB3BDkRAnugFcQUpwXH_EJ7oBbAD-ikrVJog2Z9gANoANYAPYADagG8AGJcaIxCCqpCkXR4qU38t7f9sjAEB30NFgX0uVXZi-llEUynGgVJBPgkmWTwcBikI1ynIt0mmYmumo-GZdALk9n8-Hg44A4-LFpmRGmR7XYCtPtUnOUqOtu_ftxnVY2S1WufMlr33KGgsMEW1i-ZVprcq7tvKB35PkTJIFPaFaMrTyoScbyGlEyU-5aQqyb-kjb1wUG8opa4Qtk9SxLX3idQUlY5qzv-dVL4lTK2deUwnEJCFRE2uZpM5t5UuvJ4wxRyZqm1S6UazgqngU-nXJI6R7MYpbHhun3zj9ttSJUFQQ2jIQp985_b6yiamiLP41moZDd_qD0x9LnSEYK7KiwT85_rncURLz2MDkv4-JK__iyr9WkkHUkEXXZYNkZk5_qxzERCAF4UqSeXd69VpEzBjm_fvwAzLx9Qs',
write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 user-container   source: '0507332f-6bbe-4084-a709-c452b6054871-bluemix.cloudantnosqldb.appdomain.cloud/dataproc',
write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 user-container   specversion: '0.3',
write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 user-container   subject: 'IBM_logo17981.png',
write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 user-container   time: '2019-10-25T18:41:24.189629448Z',
write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 user-container   type: 'org.apache.couchdb.document.update',
write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 user-container   data: [ '1-d66b828ed6f5ebee87fbc750a07d00ba' ]
write-from-cloudant-vp7pg-deployment-5664bc595-ldk65 user-container }
```




## Cleanup

Delete the `knative-dataprocessing` namespace:

```sh
kubectl delete namespace knative-dataprocessing
```



