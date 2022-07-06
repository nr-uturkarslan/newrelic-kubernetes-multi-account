#!/bin/bash

#################
### App Setup ###
#################

### Set variables

# Namespaces
namespaceBravo="bravo"

# Zookeeper
declare -A redis
redis["name"]="redis"
redis["image"]="redis:latest"
redis["port"]=6379
redis["replicas"]=2
redis["nodeSelector"]="storage"

####################
### Build & Push ###
####################

#########

##################
### Deploy K8s ###
##################

### Redis ###
helm upgrade redis \
  --install \
  --wait \
  --debug \
  --namespace $namespaceBravo \
  --set name=${zookeeper[name]} \
  --set image=${zookeeper[image]} \
  --set port=${zookeeper[port]} \
  --set replicas=${zookeeper[replicas]} \
  --set nodeSelector=${zookeeper[nodeSelector]} \
  "../charts/redis"
