
#!/usr/bin/env bash

(cd src/receive-activity && docker build -t $DOCKER_USER/receive-activity . && docker push $DOCKER_USER/receive-activity)
(cd src/record-assignment && docker build -t $DOCKER_USER/record-assignment . && docker push $DOCKER_USER/record-assignment)

sed "s/\$DOCKER_USER/$DOCKER_USER/" ./config/receive-activity-ksvc.yaml.tpl > ./config/receive-activity-ksvc.yaml
sed "s/\$DOCKER_USER/$DOCKER_USER/" ./config/record-assignment-ksvc.yaml.tpl > ./config/record-assignment-ksvc.yaml