apiVersion: serving.knative.dev/v1alpha1
kind: Service
metadata:
  name: last-step
spec:
  template:
    spec:
      containers:
      - image: docker.io/$DOCKER_USER/replace
        env:
        - name: REPLACEMENT
          value: '{"step": "last"}'
