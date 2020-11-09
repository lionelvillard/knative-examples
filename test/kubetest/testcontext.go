package kubetest

import (
	"context"
	"fmt"
	"strings"
	"testing"

	"github.com/onsi/gomega"
)

// --- Default implementation

type testContextImpl struct {
	context context.Context
	ns      string

	t *testing.T
	*gomega.WithT
}

var _ TestContext = (*testContextImpl)(nil)

func (kc *testContextImpl) Kubectl(args ...string) string {
	a := strings.Join(args, " ")
	if len(a) > 0 {
		a = " " + a
	}
	out, err := runCmd(fmt.Sprintf("kubectl -n %s%s", kc.ns, a))
	if err != nil {
		kc.Log(out)
		kc.Error(err)
	}
	return out
}

func (kc *testContextImpl) Create() CreateOp {
	return &kubeCmd{kc: kc, cmd: "create"}
}

func (kc *testContextImpl) Delete() DeleteOp {
	return &kubeCmd{kc: kc, cmd: "delete"}
}

func (kc *testContextImpl) Apply() ApplyOp {
	return &kubeCmd{kc: kc, cmd: "apply"}
}

type kubeCmd struct {
	kc  *testContextImpl
	cmd string
}

func (kc *kubeCmd) Namespace(ns string) {
	kc.kc.Kubectl(kc.cmd, "namespace", ns)
}

func (kc *kubeCmd) FromFile(path string) {
	kc.kc.Helper()
	kc.kc.Kubectl(kc.cmd, "-f", path)
}

func (kc *kubeCmd) FromTemplate(path string, data map[string]string) {
	kc.kc.Helper()

	if data == nil {
		data = make(map[string]string)
	}
	data["Namespace"] = kc.kc.ns

	npath, err := ParseTemplates(path, data)
	if err != nil {
		kc.kc.Error(err)
	}

	kc.kc.Kubectl(kc.cmd, "-f", npath)
}

// --- testing.T wrapper

func (c *testContextImpl) Error(args ...interface{}) {
	c.t.Error(args...)
}

func (c *testContextImpl) Errorf(format string, args ...interface{}) {
	c.t.Errorf(format, args...)
}

func (c *testContextImpl) Fail() {
	c.t.Fail()
}

func (c *testContextImpl) FailNow() {
	c.t.FailNow()
}

func (c *testContextImpl) Failed() bool {
	return c.t.Failed()
}

func (c *testContextImpl) Fatal(args ...interface{}) {
	c.t.Fatal(args...)
}

func (c *testContextImpl) Fatalf(format string, args ...interface{}) {
	c.t.Fatalf(format, args...)
}

func (c *testContextImpl) Helper() {
	c.t.Helper()
}

func (c *testContextImpl) Log(args ...interface{}) {
	c.t.Log(args...)
}

func (c *testContextImpl) Logf(format string, args ...interface{}) {
	c.t.Logf(format, args...)
}

func (c *testContextImpl) Name() string {
	return c.t.Name()
}

func (c *testContextImpl) Skip(args ...interface{}) {
	c.t.Skip(args...)
}

func (c *testContextImpl) SkipNow() {
	c.t.SkipNow()
}

func (c *testContextImpl) Skipf(format string, args ...interface{}) {
	c.t.Skipf(format, args...)
}

func (c *testContextImpl) Skipped() bool {
	return c.t.Skipped()
}
