package main

import (
	"context"
	"flag"
	"fmt"
	"io/ioutil"
	"net"
	"net/http"
	"runtime"
	"strings"
	"sync"
	"sync/atomic"
	"time"
)

var (
	portsPort int
	ips       string
	cc        int
)

func init() {
	flag.StringVar(&ips, "ips", "localhost", "where to send requests")
	flag.IntVar(&portsPort, "pp", 9000, "where to get the list of open ports")
	flag.IntVar(&cc, "cc", 3, "concurrency (connection per url)")
}

var (
	errorDoRequest = uint64(0)
	conns          = make(map[net.Conn]bool)
	connsLock      = sync.Mutex{}
)

type conn struct {
	net.Conn
}

func (c conn) Close() error {
	// fmt.Println("closing")
	connsLock.Lock()
	delete(conns, c.Conn)
	connsLock.Unlock()
	return c.Conn.Close()

}

func sendWithTransport(t *http.Transport) func(string) {
	return func(url string) {
		data := strings.NewReader("1")
		req, err := http.NewRequest("POST", url, data)
		if err != nil {
			fmt.Printf("Error new request: %v\n", err)
			return
		}

		client := &http.Client{
			Transport: t,
		}

		resp, err := client.Do(req)
		if err != nil {
			//fmt.Printf("Error req: %v\n", err)
			atomic.AddUint64(&errorDoRequest, 1)
			return
		}
		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			fmt.Printf("Error reading body: %v\n", err)
		}
		resp.Body.Close()

		if resp.StatusCode != 200 {
			fmt.Printf("Error req: %d (resp: %s)\n", resp.StatusCode, string(body))
		}
	}
}

func send(urls []string) {
	var transport = http.DefaultTransport.(*http.Transport).Clone()

	dialCount := int64(0)

	dc := transport.DialContext
	transport.DialContext = func(ctx context.Context, network, address string) (net.Conn, error) {
		atomic.AddInt64(&dialCount, 1)
		c, err := dc(ctx, network, address)

		if err != nil {
			return nil, err
		}
		connsLock.Lock()
		if ok := conns[c]; ok {
			fmt.Println("reusing")
		}
		conns[c] = true
		connsLock.Unlock()

		return conn{Conn: c}, nil
	}
	transport.IdleConnTimeout = 1 * time.Second
	transport.ForceAttemptHTTP2 = false
	transport.MaxIdleConns = 0
	transport.MaxIdleConnsPerHost = 15000
	transport.MaxConnsPerHost = 15000
	sender := sendWithTransport(transport)

	queued := make(chan string, len(urls)*cc)
	for _, url := range urls {
		for i := 0; i < cc; i++ {
			queued <- url
		}
	}

	inflight := int64(0)
	go func() {
		for {
			time.Sleep(1 * time.Second)
			fmt.Printf("inflight requests: %v\n", inflight)
			fmt.Printf("dial count: %d\n", dialCount)
			fmt.Printf("open connections: %d\n", len(conns))
			fmt.Printf("error req.do count: %d\n", errorDoRequest)

			var stats runtime.MemStats
			runtime.ReadMemStats(&stats)
			fmt.Printf("mem alloc: %v\n", stats.Alloc)
			fmt.Println("---")
		}
	}()

	for {
		select {
		case url := <-queued:
			go func() {
				atomic.AddInt64(&inflight, 1)
				sender(url)
				atomic.AddInt64(&inflight, -1)
				time.Sleep(1 * time.Second)
				queued <- url
			}()
		}
	}
}

func getUrls(host string) []string {
	resp, err := http.Get(fmt.Sprintf("http://%s:%d", host, portsPort))
	if err != nil {
		panic(err)
	}

	body, err := ioutil.ReadAll(resp.Body)
	resp.Body.Close()
	if err != nil {
		panic(err)
	}

	var urls []string

	ports := strings.Split(string(body), ",")
	for _, port := range ports {
		urls = append(urls, "http://"+host+":"+port)
	}
	return urls
}

func main() {
	flag.Parse()

	var urls []string
	for _, ip := range strings.Split(ips, ",") {
		urls = append(urls, getUrls(ip)...)
	}
	send(urls)
}
