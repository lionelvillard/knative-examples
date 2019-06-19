apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: routing-notassigned
spec:
  template:
    spec:
      containers:
      - image: $DOCKER_USER/routing-notassigned