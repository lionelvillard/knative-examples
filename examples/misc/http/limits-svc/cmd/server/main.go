package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"runtime"
	"strconv"
	"sync/atomic"
	"time"

	"github.com/gorilla/mux"
)

var (
	count int
)

func init() {
	flag.IntVar(&count, "count", 0, "The number of servers")
}

func main() {
	flag.Parse()

	ports := ""
	sep := ""

	r := mux.NewRouter()
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(200)
		w.Write([]byte(ports))
	})

	openPortsSrv := &http.Server{
		Addr:    ":9000",
		Handler: r,
	}
	go func() {
		log.Fatal(openPortsSrv.ListenAndServe())
	}()

	rcount := uint64(0)
	start := time.Now()

	go func() {
		for {
			time.Sleep(1 * time.Second)
			elapsed := time.Since(start)
			rps := float64(rcount) / elapsed.Seconds()
			fmt.Printf("rps: %v\n", rps)

			var stats runtime.MemStats
			runtime.ReadMemStats(&stats)
			fmt.Printf("mem alloc: %v\n", stats.Alloc)
			fmt.Println("---")
		}
	}()

	fmt.Printf("creating %d servers\n", count)

	done := make(chan bool, 1)

	for i := 0; i < count; i++ {
		ln, err := net.Listen("tcp", fmt.Sprintf("localhost:%d", 50000+i))
		if err != nil {
			log.Println(err)
			continue
		}
		port := ln.Addr().(*net.TCPAddr).Port
		ln.Close()
		ports = fmt.Sprintf("%s%s%d", ports, sep, port)
		sep = ","

		r := mux.NewRouter()
		r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
			atomic.AddUint64(&rcount, 1)
			body, err := ioutil.ReadAll(r.Body)
			if err != nil {
				log.Printf("Error reading body: %v", err)
				http.Error(w, "can't read body", http.StatusBadRequest)
				return
			}
			r.Body.Close()
			sleep, err := strconv.Atoi(string(body))
			if err != nil {
				http.Error(w, "bad body format", http.StatusBadRequest)
				return
			}
			time.Sleep(time.Duration(sleep) * time.Second)
			fmt.Fprintf(w, "hello from %d after %d seconds", port, sleep)

		})

		srv := &http.Server{
			Addr:    fmt.Sprintf(":%d", port),
			Handler: r,
		}

		go func() {
			fmt.Printf("starting server %v\n", srv.Addr)
			log.Fatal(srv.ListenAndServe())
			done <- true
		}()
		time.Sleep(1 * time.Millisecond)
	}
	<-done
}
