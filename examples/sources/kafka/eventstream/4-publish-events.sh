#!/usr/bin/env bash

kafkacat -F kafka.cfg -Xsasl.password=$PWD -P -t fruits
