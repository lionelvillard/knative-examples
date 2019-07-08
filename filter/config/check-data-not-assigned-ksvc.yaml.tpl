apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: check-data-not-assigned
spec:
  template:
    spec:
      containers:
      - image: $DOCKER_USER/check-data-not-assigned