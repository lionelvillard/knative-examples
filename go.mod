module github.com/lionelvillard/knative-examples

go 1.14

require (
	github.com/Shopify/sarama v1.27.0
	github.com/cloudevents/sdk-go/v2 v2.2.0
	github.com/golang/protobuf v1.4.2
	github.com/onsi/gomega v1.10.1
	github.com/slinkydeveloper/loadastic v0.0.0-20191203132749-9afe5a010a57
	github.com/tektoncd/pipeline v0.13.1-0.20200625065359-44f22a067b75 // indirect
	go.opencensus.io v0.22.5-0.20200716030834-3456e1d174b2
	go.uber.org/atomic v1.6.0
	go.uber.org/zap v1.15.0
	knative.dev/eventing v0.18.0
	knative.dev/pkg v0.0.0-20200922164940-4bf40ad82aab
)

replace (
	k8s.io/api => k8s.io/api v0.18.8
	k8s.io/apiextensions-apiserver => k8s.io/apiextensions-apiserver v0.18.8
	k8s.io/apimachinery => k8s.io/apimachinery v0.18.8
	k8s.io/client-go => k8s.io/client-go v0.18.8
	k8s.io/code-generator => k8s.io/code-generator v0.18.8
	knative.dev/eventing => knative.dev/eventing v0.18.0
	knative.dev/eventing-contrib => knative.dev/eventing-contrib v0.18.0
)
