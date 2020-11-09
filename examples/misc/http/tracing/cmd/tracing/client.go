package main

import (
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"net/http/httptrace"
	"sync"
	"time"
)

var (
	url = flag.String("url", "", "")
)

// transport is an http.RoundTripper that keeps track of the in-flight
// request and implements hooks to report HTTP tracing events.
type transport struct {
	rountripper http.RoundTripper
	current     *http.Request
}

// RoundTrip wraps http.DefaultTransport.RoundTrip to keep track
// of the current request.
func (t *transport) RoundTrip(req *http.Request) (*http.Response, error) {
	t.current = req
	return t.rountripper.RoundTrip(req)
}

// GotConn prints whether the connection has been used previously
// for the current request.
func (t *transport) GotConn(info httptrace.GotConnInfo) {
	fmt.Printf("Connection reused for %v? %v\n", t.current.URL, info.Reused)
}

func repeat(n int, jitter time.Duration, fn func()) {
	for n > 0 {
		fn()
		time.Sleep(jitter)
		n--
	}
}

func sendWithTransport(t *transport) func() {
	return func() {
		req, _ := http.NewRequest("GET", *url, nil)
		trace := &httptrace.ClientTrace{
			GotConn: t.GotConn,
		}
		req = req.WithContext(httptrace.WithClientTrace(req.Context(), trace))

		client := &http.Client{
			Transport: t,
		}

		resp, err := client.Do(req)
		if err != nil {
			fmt.Printf("Error req: %v\n", err)
		}
		io.Copy(ioutil.Discard, resp.Body)
		resp.Body.Close()
	}
}

func runNoConnReuse(n, c int) {
	var base = http.DefaultTransport.(*http.Transport).Clone()
	base.IdleConnTimeout = 100 * time.Second
	base.MaxIdleConns = 100
	base.MaxConnsPerHost = 100

	t := &transport{
		rountripper: base,
	}

	var wg sync.WaitGroup

	for i := 0; i < c; i++ {
		wg.Add(1)
		go repeat(n, 8*time.Second, sendWithTransport(t))
	}

	wg.Wait()
}

func main() {
	flag.Parse()

	runNoConnReuse(100, 100)
}
