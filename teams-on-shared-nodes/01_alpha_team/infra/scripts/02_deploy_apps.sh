#!/bin/bash

#################
### App Setup ###
#################

### Set parameters
project="nr1"
locationLong="westeurope"
locationShort="euw"
stageLong="dev"
stageShort="d"
instance="001"

platform="platform"

### Set variables

# Cluster name - AKS
clusterName="aks${project}${locationShort}${platform}${stageShort}${instance}"

# Namespaces
namespaceAlpha="alpha"
namespaceBravo="bravo"
namespaceCharlie="charlie"

# Bash logger for testing
bashLoggerName="bashlogger"

####################
### Build & Push ###
####################

# Bash Logger
docker build \
  --platform linux/amd64 \
  --tag "${DOCKERHUB_NAME}/${bashLoggerName}" \
  "../../apps/bashlogger"
docker push "${DOCKERHUB_NAME}/${bashLoggerName}"
#########

##################
### Deploy K8s ###
##################

### Namespaces ###
kubectl create namespace $namespaceAlpha
kubectl create namespace $namespaceBravo
kubectl create namespace $namespaceCharlie

### New Relic Kube Events ###
helm dependency update "../charts/nri-kube-events"
helm upgrade nri-kube-events \
  --install \
  --wait \
  --debug \
  --namespace $namespaceAlpha \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY_ALPHA \
  "../charts/nri-kube-events"

### New Relic Prometheus ###
helm dependency update "../charts/nri-prometheus"
helm upgrade nri-prometheus \
  --install \
  --wait \
  --debug \
  --namespace $namespaceAlpha \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY_ALPHA \
  "../charts/nri-prometheus"

### New Relic Logging ###
helm dependency update "../charts/nri-logging"
helm upgrade nri-logging \
  --install \
  --wait \
  --debug \
  --namespace $namespaceAlpha \
  --set global.cluster=$clusterName \
  --set namespaceAlpha=$namespaceAlpha \
  --set namespaceBravo=$namespaceBravo \
  --set namespaceCharlie=$namespaceCharlie \
  --set licenseKeyAlpha=$NEWRELIC_LICENSE_KEY_ALPHA \
  --set licenseKeyBravo=$NEWRELIC_LICENSE_KEY_BRAVO \
  --set licenseKeyCharlie=$NEWRELIC_LICENSE_KEY_CHARLIE \
  --set endpoint="https://log-api.eu.newrelic.com/log/v1" \
  "../charts/nri-logging"

### Bashlogger ###
helm upgrade $bashLoggerName \
  --install \
  --wait \
  --debug \
  --namespace $namespaceBravo \
  --set dockerhubName=$DOCKERHUB_NAME \
  --set name=$bashLoggerName \
  "../charts/$bashLoggerName"
#########
