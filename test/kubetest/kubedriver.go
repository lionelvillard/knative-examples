package kubetest

import (
	"testing"
)

// Test defines functions for configuring and running a single test case
type Test interface {

	// Run the test within the given context
	Run(fn func(tc TestContext))
}

// NewTest creates a new test case
func NewTest(t *testing.T) Test {
	return newTest(t)
}

// TestContext is the context when running a test case
type TestContext interface {
	// Create resources
	Create() CreateOp

	// Delete resources
	Delete() DeleteOp

	// Apply resources
	Apply() ApplyOp

	// Logs for Pod
	//Logs() LogsOp

	// --- Logging, Failures. Subset of testing.T

	Helper()
	Log(args ...interface{})
	Logf(format string, args ...interface{})
	Error(args ...interface{})
	Errorf(format string, args ...interface{})
	Fatal(args ...interface{})
	Fatalf(format string, args ...interface{})
}

type CreateOp interface {
	Namespace(ns string)
}

type DeleteOp interface {
	Namespace(ns string)
}

type ApplyOp interface {
	FromFile(path string)
	FromTemplate(path string, data map[string]string)
}

type LogsOp interface {
	ForPod(name string) LogsPodOp
}

type LogsPodOp interface {
	AsEvents()
}
