apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: send-message
spec:
  template:
    spec:
      containers:
      - image: $DOCKER_USER/send-message