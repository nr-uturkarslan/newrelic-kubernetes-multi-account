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
mongo["replicas"]=1
mongo["nodePoolName"]="storage"

# Redis
declare -A redis
redis["name"]="redis"
redis["image"]="redis"
redis["port"]=6379
redis["replicas"]=1
redis["nodePoolName"]="storage"

# Persistancy
declare -A persistancy
persistancy["name"]="persistancy"
persistancy["imageName"]="bravo-persistancy-service"
persistancy["appName"]="bravo-persistancy-service"
persistancy["port"]=8080
persistancy["replicas"]=1
persistancy["nodePoolName"]="general"

# Input Processor
declare -A proxy
proxy["name"]="proxy"
proxy["imageName"]="bravo-proxy-service"
proxy["appName"]="bravo-proxy-service"
proxy["port"]=8080
proxy["replicas"]=1
proxy["nodePoolName"]="general"

####################
### Build & Push ###
####################

# --platform linux/amd64 \

### Persistancy
docker build \
  --tag "${DOCKERHUB_NAME}/${persistancy[imageName]}" \
  "../../apps/bravo-persistancy-service/."
docker push "${DOCKERHUB_NAME}/${persistancy[imageName]}"

### Proxy
docker build \
  --build-arg newRelicAppName=${proxy[appName]} \
  --build-arg newRelicLicenseKey=$NEWRELIC_LICENSE_KEY_BRAVO \
  --tag "${DOCKERHUB_NAME}/${proxy[imageName]}" \
  "../../apps/bravo-proxy-service/bravo-proxy-service/."
docker push "${DOCKERHUB_NAME}/${proxy[imageName]}"

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
  --set nodePoolName=${redis[nodePoolName]} \
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
  --set nodePoolName=${mongo[nodePoolName]} \
  "../charts/mongo"

### Persistancy ###
helm upgrade ${persistancy[name]} \
  --install \
  --wait \
  --debug \
  --set dockerhubName=$DOCKERHUB_NAME \
  --namespace $namespaceBravo \
  --set name=${persistancy[name]} \
  --set namespace=$namespaceBravo \
  --set imageName=${persistancy[imageName]} \
  --set port=${persistancy[port]} \
  --set nodePoolName=${persistancy[nodePoolName]} \
  --set newRelicAppName=${persistancy[appName]} \
  --set newRelicLicenseKey=$NEWRELIC_LICENSE_KEY_BRAVO \
  "../charts/bravo-persistancy-service"

### Proxy ###
helm upgrade ${proxy[name]} \
  --install \
  --wait \
  --debug \
  --set dockerhubName=$DOCKERHUB_NAME \
  --namespace $namespaceBravo \
  --set name=${proxy[name]} \
  --set namespace=$namespaceBravo \
  --set imageName=${proxy[imageName]} \
  --set nodePoolName=${proxy[nodePoolName]} \
  --set port=${proxy[port]} \
  "../charts/bravo-proxy-service"

#########