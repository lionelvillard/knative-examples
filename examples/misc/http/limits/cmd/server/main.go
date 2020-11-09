package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"strconv"
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

	fmt.Printf("creating %d servers\n", count)

	done := make(chan bool, 1)

	for i := 0; i < count; i++ {
		ln, err := net.Listen("tcp", "localhost:0")
		if err != nil {
			log.Fatal(err)
		}
		port := ln.Addr().(*net.TCPAddr).Port
		ln.Close()
		ports = fmt.Sprintf("%s%s%d", ports, sep, port)
		sep = ","

		r := mux.NewRouter()
		r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
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
		time.Sleep(10 * time.Millisecond)
	}
	<-done
}
