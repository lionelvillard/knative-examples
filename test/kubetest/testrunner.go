package kubetest

import (
	"context"
	"strings"
	"testing"

	"github.com/onsi/gomega"
)

type test struct {
	t *testing.T
}

func newTest(t *testing.T) Test {
	return &test{t: t}
}

func (t *test) Run(fn func(TestContext)) {
	namespace := AppendRandomString(strings.ToLower(t.t.Name()))
	ctx := context.Background()

	kc := &testContextImpl{
		context: ctx,
		ns:      namespace,
		t:       t.t,
		WithT:   gomega.NewGomegaWithT(t.t),
	}

	kc.Create().Namespace(namespace)

	cleanup := func() {
		kc.Delete().Namespace(namespace)
	}

	// Clean up resources if the test is interrupted in the middle.
	CleanupOnInterrupt(cleanup, t.t.Logf)

	t.t.Logf("namespace is %s", namespace)

	// Finally run user-code
	fn(kc)

	cleanup()
}
