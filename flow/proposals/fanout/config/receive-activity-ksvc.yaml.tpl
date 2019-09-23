apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: receive-activity
spec:
  template:
    spec:
      containers:
      - image: $DOCKER_USER/receive-activity