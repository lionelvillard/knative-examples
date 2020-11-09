package main

import (
	"log"
	"net/http"
	"time"
)

type handler struct {
}

func (h *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	//delay := time.Duration(rand.Int()%1000) * time.Millisecond
	time.Sleep(50 * time.Millisecond)
	http.Error(w, "(server) Hello", http.StatusOK)
}

func main() {
	s := &http.Server{
		Addr:    ":8080",
		Handler: &handler{},
	}

	log.Fatal(s.ListenAndServe())
}
