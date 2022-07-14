#!/bin/bash

createValue() {

  local endpoint=$1

  local randomValue=$(openssl rand -base64 12)
  local randomTag=$(openssl rand -base64 12)

  echo -e "---\n"

  curl -X POST "http://${clusterIp}/${endpoint}/create" \
    -i \
    -H "Content-Type: application/json" \
    -d \
    '{
        "value": "'"${randomValue}"'",
        "tag": "'"${randomTag}"'"
    }'

  echo -e "\n"
  sleep $REQUEST_INTERVAL
}

listValues() {

  local endpoint=$1

  echo -e "---\n"

  curl -X GET "http://${clusterIp}/${endpoint}/list" \
    -i \
    -H "Content-Type: application/json"

  echo -e "\n"
  sleep $REQUEST_INTERVAL
}

####################
### SCRIPT START ###
####################

# Set variables
REQUEST_INTERVAL=5

bravoEndpoint="bravo/proxy/persistancy"
charlieEndpoint="charlie/proxy/persistence"

# Get cluster external IP
clusterIp=$(kubectl get svc \
  -n nginx \
  ingress-nginx-controller \
  -o json \
  | jq -r '.status.loadBalancer.ingress[0].ip')

echo "Cluster external IP: $clusterIp"

# Start making requests
while true
do

  # Create value
  createValue $bravoEndpoint
  createValue $charlieEndpoint

  # List values
  for i in {1..5}
  do
    listValues $bravoEndpoint
    listValues $charlieEndpoint
  done
done
