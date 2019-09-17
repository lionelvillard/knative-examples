
#!/usr/bin/env bash

dirs=./src/*
for d in $dirs
do
    name=$(basename $d)
    (cd src/$name && npm i && docker build -t $DOCKER_USER/$name . && docker push $DOCKER_USER/$name)
done
