apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: routing-choice
spec:
  template:
    spec:
      containers:
      - image: $DOCKER_USER/routing-choice