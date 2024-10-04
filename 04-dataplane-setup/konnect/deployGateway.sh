#!/bin/bash

# Check if the control plane ID , control plane Name and kpat token are passed as arguments
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <control_plane_id> <control_plane_name> <kpat_token>"
  exit 1
fi


# Define the control plane ID from the argument
CONTROL_PLANE_ID=$1
CONTROL_PLANE_NAME=$2
KPAT_TOKEN=$3

# Define the API URL with parameterized control plane ID
API_URL="https://us.api.konghq.com/v2/control-planes?filter%5Bid%5D=$CONTROL_PLANE_ID&filter%5Bname%5D=$CONTROL_PLANE_NAME"

echo "API_URL: $API_URL"

# Define the authorization token (replace this with your actual token)
AUTH_TOKEN="$KPAT_TOKEN"

# Fetch the data from the API using curl with the Authorization header
response=$(curl -s -H "Authorization: Bearer $AUTH_TOKEN" "$API_URL")


# Use jq to parse the response and extract control_plane_endpoint and telemetry_endpoint from nested config under data and remove https from the front
control_plane_endpoint=$(echo "$response" | jq -r '.data[0].config.control_plane_endpoint' | sed 's|https://||')
telemetry_endpoint=$(echo "$response" | jq -r '.data[0].config.telemetry_endpoint' | sed 's|https://||')


# Check if the values were extracted properly
if [ -z "$control_plane_endpoint" ] || [ -z "$telemetry_endpoint" ]; then
  echo "Error: Failed to fetch control_plane_endpoint or telemetry_endpoint"
  exit 1
fi

# Display the extracted values
echo "Control Plane Endpoint: $control_plane_endpoint"
echo "Telemetry Endpoint: $telemetry_endpoint"

# Deploy the Kong Gateway Data Plabe in the above control plane

# Create the kong namespace
kubectl create namespace kong

# Add the kong repo
helm repo add kong https://charts.konghq.com
helm repo update

# Create the k8s secret which needs to be added on data plane, create these certificates from UI
kubectl create secret tls kong-cluster-cert -n kong --cert=tls_edu.crt --key=tls_edu.key

# Use the values in the Helm chart
# Replace <your-helm-release> with your Helm release name
# Replace <your-namespace> with your Kubernetes namespace
# helm upgrade --install my-kong kong/kong -n kong --values ./values.yaml
helm upgrade --install my-kong kong/kong \
  --set env.cluster_control_plane=$control_plane_endpoint:443 \
  --set env.cluster_server_name=$control_plane_endpoint \
  --set env.cluster_telemetry_endpoint=$telemetry_endpoint:443 \
  --set env.cluster_telemetry_server_name=$telemetry_endpoint \
  --namespace kong --values ./values.yaml

# # Check if Helm upgrade/install succeeded
if [ $? -eq 0 ]; then
  echo "Kong Helm chart upgraded successfully with the fetched endpoints."
else
  echo "Error: Failed to upgrade Kong Helm chart."
fi
