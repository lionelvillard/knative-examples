package kubetest

import (
	"math/rand"
	"os"
	"os/signal"
	"strings"
)

const (
	letterBytes   = "abcdefghijklmnopqrstuvwxyz"
	randSuffixLen = 8
	sep           = '-'
)

// FormatLogger is a printf style function for logging in tests.
type FormatLogger func(template string, args ...interface{})

func AppendRandomString(prefix string) string {
	return strings.Join([]string{prefix, RandomString()}, string(sep))
}

// RandomString will generate a random string.
func RandomString() string {
	suffix := make([]byte, randSuffixLen)

	for i := range suffix {
		suffix[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	return string(suffix)
}

// CleanupOnInterrupt will execute the function cleanup if an interrupt signal is caught
func CleanupOnInterrupt(cleanup func(), logf FormatLogger) {
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt)
	go func() {
		for range c {
			logf("Test interrupted, cleaning up.")
			cleanup()
			os.Exit(1)
		}
	}()
}
