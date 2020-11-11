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
	"fmt"
	"log"
	"net/http"
	"sync"

	cloudeventsbindings "github.com/cloudevents/sdk-go/v2/binding"
	cloudevents "github.com/cloudevents/sdk-go/v2/event"
	cloudeventshttp "github.com/cloudevents/sdk-go/v2/protocol/http"
)

// --- event db

type eventDB struct {
	events      []cloudevents.Event
	eventsMutex sync.RWMutex
}

func (db *eventDB) RecordEvent(event cloudevents.Event) {
	db.eventsMutex.Lock()
	db.events = append(db.events, event)
	db.eventsMutex.Unlock()
}

func (db *eventDB) Events(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		db.getEvents(w, r)
	case http.MethodDelete:
		db.deleteEvents(w, r)
	default:
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
	}
}

func (db *eventDB) getEvents(w http.ResponseWriter, r *http.Request) {
	if summary, ok := r.URL.Query()["summary"]; ok {
		if len(summary) != 1 {
			http.Error(w, "multiple summary found", 400)
			return
		}
		if summary[0] != "count" {
			http.Error(w, fmt.Sprintf("invalid summary %s", summary[0]), 400)
			return
		}

		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		w.WriteHeader(200)
		db.eventsMutex.RLock()
		fmt.Fprintln(w, len(db.events))
		db.eventsMutex.RUnlock()
		return
	}

	http.Error(w, "not implemented", http.StatusNotImplemented)
}

func (db *eventDB) deleteEvents(w http.ResponseWriter, r *http.Request) {
	db.eventsMutex.Lock()
	db.events = nil
	db.eventsMutex.Unlock()
	w.WriteHeader(200)
}

// --- event display

type logger struct {
	db *eventDB
}

func (o *logger) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	m := cloudeventshttp.NewMessageFromHttpRequest(request)
	defer m.Finish(nil)

	event, eventErr := cloudeventsbindings.ToEvent(context.TODO(), m)

	fmt.Println("–––")
	if eventErr != nil {
		fmt.Println(eventErr.Error())
	} else {
		fmt.Println(event)

	}
	o.db.RecordEvent(*event)

	writer.WriteHeader(http.StatusAccepted)
}

func main() {
	db := &eventDB{
		eventsMutex: sync.RWMutex{},
	}

	wg := new(sync.WaitGroup)
	wg.Add(2)

	go func() {
		server := &http.Server{Addr: ":8080", Handler: &logger{db: db}}
		if err := server.ListenAndServe(); err != nil {
			log.Fatalf("failed to create server, %v", err)
		}
		server.Close()
		wg.Done()
	}()

	go func() {
		mux := http.NewServeMux()

		mux.HandleFunc("/events", db.Events)

		server := &http.Server{Addr: ":8081", Handler: mux}
		if err := server.ListenAndServe(); err != nil {
			log.Fatalf("failed to create server, %v", err)
		}
		server.Close()
		wg.Done()
	}()

	wg.Wait()
}
