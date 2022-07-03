#!/bin/bash

#################
### App Setup ###
#################

### Set variables

clusterName="kind-test-cluster-001"
team1="team1"
team2="team2"

# helm dependency build ../charts/nri-prometheus

# Team 1
helm upgrade nri-prometheus \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace $team1 \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY \
  ../charts/nri-prometheus

# Team 2
helm upgrade nri-prometheus \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace $team2 \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY \
  ../charts/nri-prometheus
