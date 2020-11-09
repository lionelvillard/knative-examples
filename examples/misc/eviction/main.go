package main

import (
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	sigs := make(chan os.Signal, 1)
	done := make(chan bool, 1)

	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		sig := <-sigs
		fmt.Println()
		fmt.Println(sig)
		done <- true
	}()

	http.HandleFunc("/readiness", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println("check readiness")
		w.WriteHeader(200)
		w.Write([]byte("ok"))
	})

	go func() {
		http.ListenAndServe(":8080", nil)
	}()

	fmt.Println("awaiting signal")
	<-done
	fmt.Println("waiting 10 seconds")
	time.Sleep(10 * time.Second)
	fmt.Println("exiting")
}
