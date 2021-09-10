#!/usr/bin/env bash
s=67
while true
 do
   leader=$(kubectl  -n knative-eventing get lease | grep pingsource-mt-adapter.knative.dev.eventing.pkg.adapter.mtping.reconciler.00-of-01 | awk '{print $2}' | cut -f1 -d"_")
   echo "$(date --utc +%FT%T.%3NZ) Disrupting ping. Take me to your leader $leader"
   #kubectl -n knative-eventing delete pod --now $leader
   kubectl -n knative-eventing delete pod $leader
   number=$RANDOM
   let "number %= 10"
   let "number -= 5"
   let "s += number"
   sleep $s
   export s=$((s <70 ? s : 67))
   export s=$((s >64 ? s : 67))
 done
