apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: dumper
spec:
  template:
    spec:
      containers:
      - image: docker.io/$DOCKER_USER/identity
