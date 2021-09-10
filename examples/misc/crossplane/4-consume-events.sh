#!/usr/bin/env bash

kafkacat -F kafka.cfg -Xsasl.password=$PWD -C -t fruits
