package sanity

import (
	"testing"

	"github.com/lionelvillard/knative-examples/test/kubetest"
)

func TestSanity(t *testing.T) {
	kubetest.NewTest(t).Run(sanityTest)
}

func sanityTest(kc kubetest.TestContext) {
	kc.Log("deploying application")
	kc.Apply().FromTemplate("config", nil)

	kc.Log("checking events being received")

	//	kc.Logs().AsEvents()

}
