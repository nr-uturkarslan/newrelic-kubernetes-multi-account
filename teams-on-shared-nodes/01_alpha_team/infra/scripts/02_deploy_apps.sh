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
docker build \
  --platform linux/amd64 \
  --tag "${DOCKERHUB_NAME}/${zookeeper[name]}" \
  "../../apps/kafka/zookeeper/."
docker push "${DOCKERHUB_NAME}/${zookeeper[name]}"

# Kafka
docker build \
  --platform linux/amd64 \
  --tag "${DOCKERHUB_NAME}/${kafka[name]}" \
  "../../apps/kafka/kafka/."
docker push "${DOCKERHUB_NAME}/${kafka[name]}"

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

# Alpha
helm upgrade nri-prometheus-alpha \
  --install \
  --wait \
  --debug \
  --namespace $namespaceAlpha \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY_ALPHA \
  --set rbac.clusterRoleBinding.enabled=true \
  --set rbac.roleBinding.enabled=false \
  --set config.scrape_enabled_label="prometheus.io/scrape-alpha" \
  "../charts/nri-prometheus"

# Bravo
helm upgrade nri-prometheus-bravo \
  --install \
  --wait \
  --debug \
  --namespace $namespaceBravo \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY_BRAVO \
  --set rbac.clusterRoleBinding.enabled=true \
  --set rbac.roleBinding.enabled=false \
  --set config.scrape_enabled_label="prometheus.io/scrape-bravo" \
  "../charts/nri-prometheus"

# Charlie
helm upgrade nri-prometheus-charlie \
  --install \
  --wait \
  --debug \
  --namespace $namespaceCharlie \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY_CHARLIE \
  --set rbac.clusterRoleBinding.enabled=true \
  --set rbac.roleBinding.enabled=false \
  --set config.scrape_enabled_label="prometheus.io/scrape-charlie" \
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

### New Relic Metadata ###
helm dependency update "../charts/nri-metadata-injection"
helm upgrade nri-metadata-injection \
  --install \
  --wait \
  --debug \
  --namespace $namespaceAlpha \
  --set global.cluster=$clusterName \
  --set licenseKey=$NEWRELIC_LICENSE_KEY_ALPHA \
  "../charts/nri-metadata-injection"

### Ingress Controller ###
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && \
helm repo update; \
helm upgrade ingress-nginx \
  --install \
  --wait \
  --debug \
  --namespace $namespaceAlpha \
  --set controller.replicaCount=1 \
  "ingress-nginx/ingress-nginx"

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

topicExists=$(kubectl exec -n "$namespaceAlpha" "${kafka[name]}-0" -it -- bash \
  /kafka/bin/kafka-topics.sh \
  --bootstrap-server "${kafka[name]}.$namespaceAlpha.svc.cluster.local:${kafka[port]}" \
  --list \
  | grep ${kafka[topic]})

if [[ $topicExists == "" ]]; then

  echo " -> Topic does not exist. Creating ..."
  while :
  do
    isTopicCreated=$(kubectl exec -n "$namespaceAlpha" "${kafka[name]}-0" -it -- bash \
      /kafka/bin/kafka-topics.sh \
      --bootstrap-server "${kafka[name]}.$namespaceAlpha.svc.cluster.local:${kafka[port]}" \
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
# #########
