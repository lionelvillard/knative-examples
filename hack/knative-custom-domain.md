
kubectl edit configmap config-domain -n knative-serving

example:

```
apiVersion: v1
kind: ConfigMap
data:
  <custom_domain>: |
    selector:
      app: sample
  mycluster.us-south.containers.appdomain.cloud: ""
metadata:
  name: config-domain
  namespace: knative-serving
```
