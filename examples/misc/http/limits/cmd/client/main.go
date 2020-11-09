package main

import (
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"runtime"
	"strings"
	"sync/atomic"
	"time"
)

var (
	portsPort int
	ips       string
)

func init() {
	flag.StringVar(&ips, "ips", "localhost", "where to send requests")
	flag.IntVar(&portsPort, "pp", 9000, "where to get the list of open ports")
}

func sendWithTransport(t *http.Transport) func(string) {
	return func(url string) {
		data := strings.NewReader("1")
		req, _ := http.NewRequest("POST", url, data)
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

func send(urls []string) {
	var transport = http.DefaultTransport.(*http.Transport).Clone()
	transport.IdleConnTimeout = 1 * time.Second
	transport.MaxIdleConns = 100
	transport.MaxConnsPerHost = 100
	sender := sendWithTransport(transport)

	queued := make(chan string, len(urls))
	for _, url := range urls {
		queued <- url
	}

	inflight := int64(0)
	go func() {
		for {
			time.Sleep(1 * time.Second)
			fmt.Printf("inflight requests: %v\n", inflight)

			var stats runtime.MemStats
			runtime.ReadMemStats(&stats)
			fmt.Printf("mem alloc: %v\n", stats.Alloc)
		}
	}()

	for {
		select {
		case url := <-queued:
			go func() {
				atomic.AddInt64(&inflight, 1)
				sender(url)
				atomic.AddInt64(&inflight, -1)
				time.Sleep(3 * time.Second)
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
