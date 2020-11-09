package main

import (
	"fmt"
	"time"
)

func main() {
	rl := NewRateLimiter(5)
	for {
		rl.Handle("hello")
	}
}

type rateLimiter struct {
	guard chan bool
}

func NewRateLimiter(rps int) rateLimiter {
	rl := rateLimiter{
		guard: make(chan bool),
	}

	interval := time.Duration(1.0 / float64(rps) * float64(time.Second))
	fmt.Println(interval)
	go func() {
		for {
			time.Sleep(interval)
			rl.guard <- true
		}
	}()

	return rl
}

func (rl *rateLimiter) Handle(msg string) {
	<-rl.guard
	fmt.Println(msg)
}
