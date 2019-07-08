apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: wait-assignment
spec:
  template:
    spec:
      containers:
      - image: $DOCKER_USER/wait-assignment