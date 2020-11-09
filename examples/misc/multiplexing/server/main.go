package main

import (
	"crypto/tls"
	"flag"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	var useHTTP2 bool
	flag.BoolVar(&useHTTP2, "http2", false, "Enable HTTP/2")
	flag.Parse()

	r := mux.NewRouter()
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "proto: %s", r.Proto)
	})

	tlsConfig := &tls.Config{}
	log.Printf("HTTP/2 enabled: %t", useHTTP2)
	if useHTTP2 {
		tlsConfig.NextProtos = []string{"h2"}
	} else {
		tlsConfig.NextProtos = []string{"http/1.1"}
	}

	srv := &http.Server{
		Addr:      ":8000",
		Handler:   r,
		TLSConfig: tlsConfig,
	}

	log.Fatal(srv.ListenAndServeTLS("server.crt", "server.key"))
}
