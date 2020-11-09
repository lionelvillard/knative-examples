#!/usr/bin/env bash

 echo "GET https://localhost:8000"  | vegeta attack -keepalive=false  -duration=5s -rate=0 -max-workers=10 -insecure -body=payload.txt | tee results.bin | vegeta report
