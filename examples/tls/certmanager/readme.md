Enable TLS

1. Install Cluster CA issuer: k apply -f .
2. Configure knative-serving: 
    
    $ kubectl edit configmap config-certmanager --namespace knative-serving

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-certmanager
  namespace: knative-serving
  labels:
    networking.knative.dev/certificate-provider: cert-manager
data:
  issuerRef: |
    kind: ClusterIssuer
    name: letsencrypt-http01-issuer
```

3. Turn on TLS:

kubectl edit configmap config-network --namespace knative-serving

```yaml
..
data:
...
  autoTLS: Enabled
...

```
