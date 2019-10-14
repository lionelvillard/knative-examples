# Prerequites

- Knative 0.7+
- Optional: [stern](https://github.com/wercker/stern)

# Deploy

```sh
kubectl apply -f config/
```

Observe events:

```sh
stern event-display
```
Observe the log:

```
+ event-display-589879cf88-flgxh › event-display
event-display-589879cf88-flgxh event-display ☁️  cloudevents.Event
event-display-589879cf88-flgxh event-display Validation: valid
event-display-589879cf88-flgxh event-display Context Attributes,
event-display-589879cf88-flgxh event-display   specversion: 0.3
event-display-589879cf88-flgxh event-display   type: dev.knative.cronjob.event
event-display-589879cf88-flgxh event-display   source: /apis/v1/namespaces/tt/cronjobsources/add-product
event-display-589879cf88-flgxh event-display   id: 8ae69857-6bb3-41fb-9a07-18d1c0424336
event-display-589879cf88-flgxh event-display   time: 2019-10-14T19:47:00.012709866Z
event-display-589879cf88-flgxh event-display   datacontenttype: application/json
event-display-589879cf88-flgxh event-display Data,
event-display-589879cf88-flgxh event-display   {
event-display-589879cf88-flgxh event-display     "brand": "POLO RALPH LAUREN",
event-display-589879cf88-flgxh event-display     "category": "Socks for Men",
event-display-589879cf88-flgxh event-display     "name": "Polo Ralph Lauren 3-Pack Socks"
event-display-589879cf88-flgxh event-display   }
```
