apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: record-assignment
spec:
  template:
    spec:
      containers:
      - image: $DOCKER_USER/record-assignment