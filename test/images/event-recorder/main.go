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
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	cloudeventsbindings "github.com/cloudevents/sdk-go/v2/binding"
	cloudeventshttp "github.com/cloudevents/sdk-go/v2/protocol/http"
)

type logger struct{}

func (o *logger) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	m := cloudeventshttp.NewMessageFromHttpRequest(request)
	defer m.Finish(nil)

	event, eventErr := cloudeventsbindings.ToEvent(context.TODO(), m)

	fmt.Println("–––")
	if eventErr != nil {
		fmt.Println(eventErr.Error())
	} else {
		b, err := json.Marshal(event)
		if err != nil {
			fmt.Printf("error marshalling event to json: %v\n", err)
		}
		sEnc := base64.StdEncoding.EncodeToString(b)
		fmt.Println(sEnc)
	}

	writer.WriteHeader(http.StatusAccepted)
}

func main() {
	server := &http.Server{Addr: ":8080", Handler: &logger{}}
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("failed to create server, %v", err)
	}

	server.Close()
}
