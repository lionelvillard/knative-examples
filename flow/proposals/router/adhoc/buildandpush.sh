
#!/usr/bin/env bash

(cd choice && docker build -t $DOCKER_USER/routing-choice . && docker push $DOCKER_USER/routing-choice)
(cd assigned && docker build -t $DOCKER_USER/routing-assigned . && docker push $DOCKER_USER/routing-assigned)
(cd notassigned && docker build -t $DOCKER_USER/routing-notassigned . && docker push $DOCKER_USER/routing-notassigned)

sed "s/\$DOCKER_USER/$DOCKER_USER/" ./config/ksvc-assigned.yaml.tpl > ./config/ksvc-assigned.yaml
sed "s/\$DOCKER_USER/$DOCKER_USER/" ./config/ksvc-choice.yaml.tpl > ./config/ksvc-choice.yaml
sed "s/\$DOCKER_USER/$DOCKER_USER/" ./config/ksvc-notassigned.yaml.tpl > ./config/ksvc-notassigned.yaml