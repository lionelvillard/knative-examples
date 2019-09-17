apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: check-data-assigned
spec:
  template:
    spec:
      containers:
      - image: $DOCKER_USER/check-data-assigned