package main

import (
	"context"
	"io"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"net/http/httptest"
)

func main() {
	s := httptest.NewUnstartedServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		for k, vs := range r.Header {
			for _, v := range vs {
				log.Println("request header:", k, v)
			}
		}
		http.Error(w, "Hello", http.StatusOK)
	}))
	s.Config.ConnState = func(c net.Conn, s http.ConnState) {
		log.Println("connection state:", c.RemoteAddr(), s)
	}
	s.Start()
	defer s.Close()

	t := http.DefaultTransport.(*http.Transport).Clone()
	t.MaxIdleConnsPerHost = -1
	c := &http.Client{Transport: t}

	hookConnections(t) // Used to show that connection is closed.

	r, err := c.Get(s.URL)
	if err != nil {
		log.Fatal(err)
	}
	io.Copy(ioutil.Discard, r.Body)

	log.Println("done")
	r.Body.Close()

}

// The purpose of the remaining code is to log calls to net.Conn Close.
// The code is not needed to disable the pool.

func hookConnections(t *http.Transport) {
	dc := t.DialContext
	t.DialContext = func(ctx context.Context, network, address string) (net.Conn, error) {
		c, err := dc(ctx, network, address)
		return conn{c}, err
	}
}

type conn struct {
	net.Conn
}

func (c conn) Close() error {
	log.Println("conn close", c.LocalAddr())
	return c.Conn.Close()

}
