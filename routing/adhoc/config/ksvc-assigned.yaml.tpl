apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: routing-assigned
spec:
  template:
    spec:
      containers:
      - image: $DOCKER_USER/routing-assigned
