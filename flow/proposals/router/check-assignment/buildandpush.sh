
#!/usr/bin/env bash

(cd src/check-data-assigned && docker build -t $DOCKER_USER/check-data-assigned . && docker push $DOCKER_USER/check-data-assigned)
(cd src/check-data-not-assigned && docker build -t $DOCKER_USER/check-data-not-assigned . && docker push $DOCKER_USER/check-data-not-assigned)
(cd src/send-message && docker build -t $DOCKER_USER/send-message . && docker push $DOCKER_USER/send-message)

sed "s/\$DOCKER_USER/$DOCKER_USER/" ./config/check-data-assigned-ksvc.yaml.tpl > ./config/check-data-assigned-ksvc.yaml
sed "s/\$DOCKER_USER/$DOCKER_USER/" ./config/check-data-not-assigned-ksvc.yaml.tpl > ./config/check-data-not-assigned-ksvc.yaml
sed "s/\$DOCKER_USER/$DOCKER_USER/" ./config/send-message-ksvc.yaml.tpl > ./config/send-message-ksvc.yaml