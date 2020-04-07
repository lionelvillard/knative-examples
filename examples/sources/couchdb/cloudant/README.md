# Prerequites

- Knative 0.10+
- Optional: [stern](https://github.com/wercker/stern)

You also need access to a CouchDB database. In this documentation I'm using [Cloudant](https://www.ibm.com/cloud/cloudant)

# Deploy


1. You first need to create a k8s secret containing the `url` pointing to Cloudant:

```
./create-secret <service-key-name>
```

For more information about service keys, look at the [documentation(https://cloud.ibm.com/docs/resources?topic=resources-service_credentials)

2. Make sure to have a database called `photographers`

3. Deploy:

```
kubectl apply -f config/
```

4. Observe the log:

```
$ stern event -c user-
event-display-jmf2r-deployment-547688c664-wdlmb user-container ☁️  cloudevents.Event
event-display-jmf2r-deployment-547688c664-wdlmb user-container Validation: valid
event-display-jmf2r-deployment-547688c664-wdlmb user-container Context Attributes,
event-display-jmf2r-deployment-547688c664-wdlmb user-container   specversion: 0.3
event-display-jmf2r-deployment-547688c664-wdlmb user-container   type: dev.knative.couchdb.changes
event-display-jmf2r-deployment-547688c664-wdlmb user-container   source: d70caa7f-0a1a-4d38-b04a-fa62d2f7338e-bluemix.cloudantnosqldb.appdomain.cloud.photographers
event-display-jmf2r-deployment-547688c664-wdlmb user-container   subject: d2613d072443997521ee02bd5879ca6c
event-display-jmf2r-deployment-547688c664-wdlmb user-container   id: 5-g1AAAAXneJyt1M1NwzAYgGGLghAnugFcQUqJ4yaxT3QD2ADs77NVqjZBNDnDBrABbAAbwAawAWwAG5RYlmgMahWaXhwpUp5Yr3_GhJDusIPkABXkV3qAivXUJAAIymkwzctiGNCoB-O8RJkVvUwX4-qTDUnU7mw2Gw07kkyqF9sIIRMpQ7JTZqjNRabRsoc_LKVNXNWtRrXn0XHIkMv-b3o-Y9FI3rfykSfrCEMUyWI5biSHVj72ZMlTxYRcLDeqrAZWPvFkzo2RUdw69KmlzzyaJcCRQdvQ51bO_SWkzKDkbUNfWvnak_tCAUSmZehssxrJTfWo8NvaBok5VzRtG9vxd46_rx2aUGoml-ySRsGd_uD0x9rkgfdFtERvFN3pT05_nusAnIpkPeFfnP46141AKdNoPeHfHP9emzzTgsIffqXwH07_tPqWO0cqTqWA_3grL8yX-3v9UjNaUe5dEKNvhDDWsw
event-display-jmf2r-deployment-547688c664-wdlmb user-container   time: 2019-10-16T20:21:16.796316784Z
event-display-jmf2r-deployment-547688c664-wdlmb user-container   datacontenttype: application/json
event-display-jmf2r-deployment-547688c664-wdlmb user-container Data,
event-display-jmf2r-deployment-547688c664-wdlmb user-container  [
event-display-jmf2r-deployment-547688c664-wdlmb user-container     "5-5bb7ac70e315f379a21c522515293544"
event-display-jmf2r-deployment-547688c664-wdlmb user-container  ]
```

5. Add a document to the photographer database

```
./create-document.sh <service-key-name> 
```