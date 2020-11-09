#!/usr/bin/env bash

 echo "GET https://localhost:8000"  | vegeta attack   -duration=5s -rate=0 -max-workers=10 -insecure -body=payload-small.txt | tee results.bin | vegeta report
