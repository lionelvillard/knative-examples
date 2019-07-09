
#!/usr/bin/env bash

files=./config/*.tpl
for f in $files
do
    sed "s/\$DOCKER_USER/$DOCKER_USER/"  $f > ${f%%.tpl}
done

kubectl apply -f config