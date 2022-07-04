#!/bin/bash

#################
### App Setup ###
#################

### Set variables

bashLoggerName="bashlogger"

clusterName="kind-test-cluster-001"
team1="team1"
team2="team2"

####################
### Build & Push ###
####################

# Bash Logger
docker build \
  --tag $bashLoggerName \
  ../apps/bashlogger
docker push "${DOCKERHUB_NAME}/${bashLoggerName}"
#########

##############
### TEAM 1 ###
##############

### New Relic Prometheus ###
helm dependency build "../charts/nri-prometheus"
helm upgrade nri-prometheus \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace $team1 \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY \
  "../charts/nri-prometheus"

### New Relic Logging ###
helm dependency build "../charts/nri-logging"
helm upgrade nri-logging \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace $team1 \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY \
  "../charts/nri-logging"

### Bashlogger ###
helm upgrade $bashLoggerName \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace $team1 \
  --set dockerhubName=$DOCKERHUB_NAME \
  --set name=$bashLoggerName \
  "../charts/$bashLoggerName"
#########
