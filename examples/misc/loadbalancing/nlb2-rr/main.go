package main

import (
	"context"
	"flag"
	"fmt"
	"log"

	cloudevents "github.com/cloudevents/sdk-go"
)

var (
	targetURL string
)

func init() {
	flag.StringVar(&targetURL, "target", "", "The target URL for the event destination.")
}

func gotEvent(event cloudevents.Event, resp *cloudevents.EventResponse) error {
	log.Println("receive event")
	c, _ := cloudevents.NewDefaultClient()
	ctx := cloudevents.ContextWithTarget(context.Background(), targetURL)

	_, _, err := c.Send(ctx, event)
	if err == nil {
		fmt.Println("ok")
		resp.RespondWith(200, nil)
	} else {
		fmt.Printf("not ok: %v\n", err)
		resp.RespondWith(400, nil)
	}

	return nil
}

func main() {
	// parse the command line flags
	flag.Parse()
	log.Printf("the target: %v\n", targetURL)

	c, err := cloudevents.NewDefaultClient()
	if err != nil {
		log.Fatalf("failed to create client, %v", err)
	}

	log.Printf("listening on 8080")
	log.Fatalf("failed to start receiver: %s", c.StartReceiver(context.Background(), gotEvent))
}
