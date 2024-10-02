#!/bin/bash

# Check if the control plane ID, control plane name, and KPAT token are passed as arguments
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <control_plane_id> <control_plane_name> <kpat_token>"
  exit 1
fi

# Define the control plane ID, name, and KPAT token from the arguments
CONTROL_PLANE_ID=$1
CONTROL_PLANE_NAME=$2
KPAT_TOKEN=$3

# Set default region to eu, change this depending on your Kong Konnect region.
REGION="eu"

# Define the API URL to fetch control plane information
API_URL="https://$REGION.api.konghq.com/v2/control-planes?filter%5Bid%5D=$CONTROL_PLANE_ID&filter%5Bname%5D=$CONTROL_PLANE_NAME"

echo "API_URL: $API_URL"

# Fetch the control plane information using curl with the Authorization header
response=$(curl -s -H "Authorization: Bearer $KPAT_TOKEN" "$API_URL")

# Use jq to parse the response and extract control_plane_endpoint and telemetry_endpoint
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

# Generate a self-signed certificate
echo "Generating self-signed certificate..."
openssl req -new -x509 -nodes -newkey rsa:2048 -subj "/CN=kongdp/C=US" -keyout ./tls.key -out ./tls.crt > /dev/null 2>&1

# Reformat the certificate into a single line for the API call
export CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' tls.crt)

# POST the certificate to the control plane using the Konnect API
echo "Uploading certificate to control plane..."
UPLOAD_URL="https://$REGION.api.konghq.com/v2/control-planes/$CONTROL_PLANE_ID/dp-client-certificates"

# Make the POST request without printing the response
curl -s -X POST "$UPLOAD_URL" --json '{"cert":"'"$CERT"'"}' \
    --header "Authorization: Bearer ${KPAT_TOKEN}" > /dev/null

# Check if the upload succeeded
if [ $? -eq 0 ]; then
  echo "Certificate uploaded successfully."
else
  echo "Error: Failed to upload certificate."
  exit 1
fi

# Deploy the Kong Gateway Data Plane with Docker, using the fetched certificates
echo "Starting Docker container with Kong Data Plane..."

# Define the Docker command
docker run -d \
  --name my-kong-via-docker \
  -e "KONG_ROLE=data_plane" \
  -e "KONG_DATABASE=off" \
  -e "KONG_VITALS=off" \
  -e "KONG_CLUSTER_MTLS=pki" \
  -e "KONG_CLUSTER_CONTROL_PLANE=${control_plane_endpoint}:443" \
  -e "KONG_CLUSTER_SERVER_NAME=${control_plane_endpoint}" \
  -e "KONG_CLUSTER_TELEMETRY_ENDPOINT=${telemetry_endpoint}:443" \
  -e "KONG_CLUSTER_TELEMETRY_SERVER_NAME=${telemetry_endpoint}" \
  -e "KONG_CLUSTER_CERT=/etc/kong/tls/tls.crt" \
  -e "KONG_CLUSTER_CERT_KEY=/etc/kong/tls/tls.key" \
  -e "KONG_LUA_SSL_TRUSTED_CERTIFICATE=system" \
  -e "KONG_KONNECT_MODE=on" \
  -p 8000:8000 \
  -p 8443:8443 \
  -v $(pwd)/tls.crt:/etc/kong/tls/tls.crt \
  -v $(pwd)/tls.key:/etc/kong/tls/tls.key \
  kong/kong-gateway:3.8.0.0

# Check if Docker run succeeded
if [ $? -eq 0 ]; then
  echo "Kong Data Plane Docker container started successfully."
else
  echo "Error: Failed to start Kong Data Plane Docker container."
fi
