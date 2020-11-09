package main

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	sigs := make(chan os.Signal, 1)
	done := make(chan bool)

	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		sig := <-sigs
		fmt.Println()
		fmt.Println(sig)
		close(done)
	}()

	go func() {
		for {
			select {
			case <-done:
				fmt.Println("done after 2")
				time.Sleep(time.Second * 8)
				fmt.Println("done")
				return
			case <-time.After(1 * time.Second):
				fmt.Println("tick")
			}
		}
	}()

	<-done

	fmt.Println("sleeping ...")
	time.Sleep(3 * time.Second)
	fmt.Println("quitting")
}
