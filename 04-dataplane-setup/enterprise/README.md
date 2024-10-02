# Kong Control Plane Endpoints, Certificates Fetcher & Docker Deployment Installer

This script automates the process of fetching the `control_plane_endpoint` and `telemetry_endpoint` from the Kong API and deploys a Kong Data Plane using Docker with these dynamically retrieved values. It is particularly useful for users who want to configure Kong environments without manually entering control plane information.

## Features:
- Fetches `control_plane_endpoint` and `telemetry_endpoint` dynamically from the Kong API.
- Deploys a Kong Data Plane using Docker with the appropriate configuration.
- Supports passing the `control_plane_id`, `control_plane_name`, and `kpat_token` as arguments.
- Strips the `https://` prefix from `control_plane_endpoint` for use in Docker configuration.

## Prerequisites:
- **Docker**: Ensure Docker is installed and running. You can install Docker by following the [official instructions](https://docs.docker.com/get-docker/).
- **jq**: The script uses `jq` to parse JSON responses. You can install `jq` by running:
  ```bash
  sudo apt-get install jq
  ```

## Usage
### Step 1: Clone the repository or download the script
```bash
git clone git@github.com:Kong/edu-kong-enablement.git
cd edu-kong-enablement/04-dataplane-setup/enterprise
```

### Step 2: Run the script
The script requires three arguments:

- Control Plane ID: The ID of the control plane you wish to query.
- Control Plane Name: The Name of the control plane you wish to query.
- kpat Token: The token for authentication with the Kong API.

To run the script, use the following syntax:

```bash
./deployGateway.sh <control_plane_id> <control_plane_name> <kpat_token>
```

### Step 3: Docker Deployment
The script will:

Fetch the `control_plane_endpoint` and `telemetry_endpoint` values.
Deploy the Kong Data Plane with the appropriate Docker configuration.
Make sure to replace the placeholders in the script for:

`your-docker-release`: The name of your Docker container.

The script runs the following Docker command:

```bash
docker run -d \
  --name <your-docker-release> \
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
```

You can customize the Docker parameters by modifying the script directly or by passing additional options in the Docker command as needed.

## Output:
The script will display the fetched `control_plane_endpoint` and `telemetry_endpoint` before performing the Docker deployment. For example:

```bash
Control Plane Endpoint: mycluster.us.cp0.konghq.com:443
Telemetry Endpoint: telemetry.us.cp0.konghq.com
```

If the Docker deployment is successful, you'll see:

```bash
Kong Data Plane Docker container started successfully.
```

If there are any errors in the process, the script will notify you accordingly.

```bash
Error: Failed to start Kong Data Plane Docker container.
```