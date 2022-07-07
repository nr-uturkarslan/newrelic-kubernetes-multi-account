#!/bin/bash

#################
### App Setup ###
#################

### Set variables

# Namespaces
namespaceBravo="bravo"

# Mongo
declare -A mongo
mongo["name"]="mongo"
mongo["image"]="mongo"
mongo["port"]=27017
mongo["replicas"]=2
mongo["nodeSelector"]="storage"

# Redis
declare -A redis
redis["name"]="redis"
redis["image"]="redis"
redis["port"]=6379
redis["replicas"]=1
redis["nodeSelector"]="storage"

# Persistancy
declare -A persistancy
persistancy["name"]="persistancy"
persistancy["imageName"]="persistancy"
persistancy["port"]=8080
persistancy["replicas"]=2
persistancy["nodeSelector"]="general"

####################
### Build & Push ###
####################

### Persistancy
docker build \
  --tag "${DOCKERHUB_NAME}/${persistancy[imageName]}" \
  "../../apps/bravo-persistancy-service/."
docker push "${DOCKERHUB_NAME}/${persistancy[imageName]}"
###

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
  --set name=${redis[name]} \
  --set namespace=$namespaceBravo \
  --set image=${redis[image]} \
  --set port=${redis[port]} \
  --set replicas=${redis[replicas]} \
  --set nodeSelector=${redis[nodeSelector]} \
  "../charts/redis"

### Mongo ###
helm upgrade mongo \
  --install \
  --wait \
  --debug \
  --namespace $namespaceBravo \
  --set name=${mongo[name]} \
  --set namespace=$namespaceBravo \
  --set image=${mongo[image]} \
  --set port=${mongo[port]} \
  --set replicas=${mongo[replicas]} \
  --set nodeSelector=${mongo[nodeSelector]} \
  "../charts/mongo"

###################
### Persistancy ###
###################
helm upgrade ${persistancy[name]} \
  --install \
  --wait \
  --debug \
  --set dockerhubName=$DOCKERHUB_NAME \
  --namespace $namespaceBravo \
  --set name=${persistancy[name]} \
  --set namespace=$namespaceBravo \
  --set imageName=${persistancy[imageName]} \
  --set namespace=${persistancy[namespace]} \
  --set port=${persistancy[port]} \
  --set newRelicLicenseKey=$NEWRELIC_LICENSE_KEY_BRAVO \
  "../charts/bravo-persistancy-service"

#########