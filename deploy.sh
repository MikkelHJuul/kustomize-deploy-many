#!/bin/bash
build-yaml.sh "$1" | envsubst | kubectl apply -f - 
