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

# Zookeeper
declare -A zookeeper
zookeeper["name"]="zookeeper"
zookeeper["port"]=2181

# Kafka
declare -A kafka
kafka["name"]="kafka"
kafka["port"]=9092
kafka["topic"]=$namespaceCharlie

# Bash logger for testing
bashLoggerName="bashlogger"

####################
### Build & Push ###
####################

# --platform linux/amd64 \

# Zookeeper
echo -e "\n--- Zookeeper ---\n"
docker build \
  --tag "${DOCKERHUB_NAME}/${zookeeper[name]}" \
  "../../apps/kafka/zookeeper/."
docker push "${DOCKERHUB_NAME}/${zookeeper[name]}"
echo -e "\n------\n"

# Kafka
echo -e "\n--- Kafka ---\n"
docker build \
  --tag "${DOCKERHUB_NAME}/${kafka[name]}" \
  "../../apps/kafka/kafka/."
docker push "${DOCKERHUB_NAME}/${kafka[name]}"
echo -e "\n------\n"

# # Bash Logger
# docker build \
#   --platform linux/amd64 \
#   --tag "${DOCKERHUB_NAME}/${bashLoggerName}" \
#   "../../apps/bashlogger"
# docker push "${DOCKERHUB_NAME}/${bashLoggerName}"
#########

##################
### Deploy K8s ###
##################

### Namespaces ###
kubectl create namespace $namespaceAlpha
kubectl create namespace $namespaceBravo
kubectl create namespace $namespaceCharlie

### New Relic Infrastructure ###
helm dependency update "../charts/nri-infrastructure"
helm upgrade nri-infrastructure \
  --install \
  --wait \
  --debug \
  --namespace $namespaceAlpha \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY_ALPHA \
  "../charts/nri-infrastructure"

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

### Zookeeper ###
helm upgrade ${zookeeper[name]} \
  --install \
  --wait \
  --debug \
  --namespace $namespaceAlpha \
  --set dockerhubName=$DOCKERHUB_NAME \
  --set name=${zookeeper[name]} \
  --set namespace=$namespaceAlpha \
  --set port=${zookeeper[port]} \
  "../charts/kafka/zookeeper"

### Kafka ###
helm upgrade ${kafka[name]} \
  --install \
  --wait \
  --debug \
  --namespace $namespaceAlpha \
  --set dockerhubName=$DOCKERHUB_NAME \
  --set name=${kafka[name]} \
  --set namespace=$namespaceAlpha \
  --set port=${kafka[port]} \
  "../charts/kafka/kafka"

# Topic
echo "Checking topic [${kafka[topic]}] ..."

topicExists=$(kubectl exec -n "${kafka[namespace]}" "${kafka[name]}-0" -it -- bash \
  /kafka/bin/kafka-topics.sh \
  --bootstrap-server "${kafka[name]}.${kafka[namespace]}.svc.cluster.local:${kafka[port]}" \
  --list \
  | grep ${kafka[topic]})

if [[ $topicExists == "" ]]; then

  echo " -> Topic does not exist. Creating ..."
  while :
  do
    isTopicCreated=$(kubectl exec -n "${kafka[namespace]}" "${kafka[name]}-0" -it -- bash \
      /kafka/bin/kafka-topics.sh \
      --bootstrap-server "${kafka[name]}.${kafka[namespace]}.svc.cluster.local:${kafka[port]}" \
      --create \
      --topic ${kafka[topic]} \
      2> /dev/null)

    if [[ $isTopicCreated == "" ]]; then
      echo " -> Kafka pods are not fully ready yet. Waiting ..."
      sleep 2
      continue
    fi

    echo -e " -> Topic is created successfully.\n"
    break

  done
else
  echo -e " -> Topic already exists.\n"
fi
#########

# ### Bashlogger ###
# helm upgrade $bashLoggerName \
#   --install \
#   --wait \
#   --debug \
#   --namespace $namespaceBravo \
#   --set dockerhubName=$DOCKERHUB_NAME \
#   --set name=$bashLoggerName \
#   "../charts/$bashLoggerName"
#########
