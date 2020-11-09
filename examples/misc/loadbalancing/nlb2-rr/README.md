
1. Create a ConfigMap called `config-mako`  
```
kubectl create ns rr
kubectl create configmap -n rr config-mako --from-file=./dev.config
```

1. Install the eventing resources for attacking:

   ```
   ko apply -f perf-setup.yaml
   ```

1. Start the benchmarking job:

   ```
   ko apply -f perf.yaml
   ```

1. Retrieve results  

   ```
   ./read_results.sh perf-aggregator rr ${mako_port:-10001} ${timeout:-120} ${retries:-100} ${retries_interval:-10} result.csv
   ```

   This will download a CSV with all raw results.

1. Plot

   ``` 
   gnuplot -c latency-and-thpt-plot.plg result.csv 0.005 480 520
   ```
