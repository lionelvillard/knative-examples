#!/usr/bin/env bash

set -e

KO_DOCKER_REPO=docker.io/knativeexamples

ko publish -B github.com/lionelvillard/knative-examples/test/images/event-recorder
ko publish -B github.com/lionelvillard/knative-examples/test/images/event-sender
ko publish -B github.com/lionelvillard/knative-examples/test/images/event-receiver
