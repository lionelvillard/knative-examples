/*
Copyright 2019 The Knative Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"strconv"
	"time"

	"go.uber.org/atomic"

	cloudevents "github.com/cloudevents/sdk-go/v2"
)

var (
	filter   bool
	count    atomic.Int64
	delayStr string
)

func init() {
	flag.StringVar(&delayStr, "delay", "0", "The number of milliseconds to wait before replying.")
}

func gotEvent(delay time.Duration) interface{} {
	return func(event cloudevents.Event) {
		count.Add(1)

		time.Sleep(delay)
	}
}

func main() {
	flag.Parse()
	delay := parseDurationStr(delayStr, 500)

	go func() {
		for {
			time.Sleep(time.Second)
			fmt.Printf("received event/s = %d\n", count.Load())
			count.Store(0)
		}
	}()

	c, err := cloudevents.NewDefaultClient()
	if err != nil {
		log.Fatalf("failed to create client, %v", err)
	}

	log.Printf("listening on 8080")
	log.Fatalf("failed to start receiver: %s", c.StartReceiver(context.Background(), gotEvent(delay)))
}

func parseDurationStr(durationStr string, defaultDuration int) time.Duration {
	var duration time.Duration
	if d, err := strconv.Atoi(durationStr); err != nil {
		duration = time.Duration(defaultDuration) * time.Millisecond
	} else {
		duration = time.Duration(d) * time.Millisecond
	}
	return duration
}
