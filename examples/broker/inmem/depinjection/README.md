# Trigger with dependency injection

This example shows how to receive all events from a specific source by
annotating triggers with `knative.dev/dependency`.

Topology:

```
ping-source-1                   trigger-1 -> event-display-1
                -> broker ->
ping-source-2                   trigger-2 -> event-display-2
```

Run:

- `./0-start-kind.sh`
- `./1-setup-cluster.sh`
- `./3-deploy.sh`

Observe:

- `kubectl logs -lapp=event-display-1`: shows events coming from `ping-source-1`
- `kubectl logs -lapp=event-display-2`: shows events coming from `ping-source-2`

Cleanup:

- `./8-cleanup.sh`
