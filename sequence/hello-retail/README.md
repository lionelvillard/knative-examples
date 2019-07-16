# Prerequites

- Knative 0.7
- Optional: [stern](https://github.com/wercker/stern)

# Deploy

```sh
kubectl apply -f config/
```

In one terminal, watch for service logs:

```sh
stern 'assign|send|wait|event' -c user-container
```

Send an event:

```sh
./sendevent.sh
```

Observe the log:

```
+ assign-photographer-t8vsj-deployment-56774bf495-br7h6 › user-container
assign-photographer-t8vsj-deployment-56774bf495-br7h6 user-container
assign-photographer-t8vsj-deployment-56774bf495-br7h6 user-container > @ start /app
assign-photographer-t8vsj-deployment-56774bf495-br7h6 user-container > node index.js
assign-photographer-t8vsj-deployment-56774bf495-br7h6 user-container
assign-photographer-t8vsj-deployment-56774bf495-br7h6 user-container assigned photographer
assign-photographer-t8vsj-deployment-56774bf495-br7h6 user-container photographer assigned Mike
+ send-assignment-notice-f9dfc-deployment-5d7998cb59-cc7rb › user-container
send-assignment-notice-f9dfc-deployment-5d7998cb59-cc7rb user-container
send-assignment-notice-f9dfc-deployment-5d7998cb59-cc7rb user-container > @ start /app
send-assignment-notice-f9dfc-deployment-5d7998cb59-cc7rb user-container > node index.js
send-assignment-notice-f9dfc-deployment-5d7998cb59-cc7rb user-container
send-assignment-notice-f9dfc-deployment-5d7998cb59-cc7rb user-container send assignment notice
send-assignment-notice-f9dfc-deployment-5d7998cb59-cc7rb user-container Hello Mike! Please snap a pic of: Polo Ralph Lauren 3-Pack Socks Created by: POLO RALPH LAUREN
+ wait-for-photo-hbldt-deployment-67cb9f57fb-xwjnd › user-container
wait-for-photo-hbldt-deployment-67cb9f57fb-xwjnd user-container
wait-for-photo-hbldt-deployment-67cb9f57fb-xwjnd user-container > @ start /app
wait-for-photo-hbldt-deployment-67cb9f57fb-xwjnd user-container > node index.js
wait-for-photo-hbldt-deployment-67cb9f57fb-xwjnd user-container
wait-for-photo-hbldt-deployment-67cb9f57fb-xwjnd user-container wait for photo
+ event-display-pkvhl-deployment-8fddfc758-zg6bp › user-container
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container ☁️  cloudevents.Event
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container Validation: valid
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container Context Attributes,
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container   specversion: 0.3
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container   type: com.hello-retail.product.created
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container   source: localhost
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container   id: 1
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container   datacontenttype: application/json; charset=utf-8
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container Extensions,
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container   knativehistory: acquire-photo-kn-sequence-2-kn-channel.default.svc.cluster.local, acquire-photo-kn-sequence-0-kn-channel.default.svc.cluster.local, acquire-photo-kn-sequence-1-kn-channel.default.svc.cluster.local
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container Data,
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container   {
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container     "data": {
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container       "brand": "POLO RALPH LAUREN",
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container       "name": "Polo Ralph Lauren 3-Pack Socks",
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container       "category": "Socks for Men"
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container     },
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container     "photographers": [
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container       "Mike"
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container     ],
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container     "photographer": {
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container       "id": "Mike",
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container       "name": "Mike"
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container     },
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container     "assigned": true,
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container     "assignmentComplete": false
event-display-pkvhl-deployment-8fddfc758-zg6bp user-container   }
```
