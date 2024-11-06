# Kong Control Plane Endpoint Fetcher & Helm Chart Installer

This script automates the process of fetching `control_plane_endpoint`, `telemetry_endpoint` and `control_plane_id` from the Kong API and installs/upgrades a Kong Helm chart using these dynamically retrieved values. It is particularly useful for users who want to configure Kong environments without manually entering control plane information.

## Features:
- Fetches `control_plane_endpoint`, `telemetry_endpoint` and `control_plane_id` dynamically from the Kong API.
- Installs or upgrades the Kong Helm chart using these values.
- Uploads the certificate on Control Plane for securing ethe communication
- Supports passing the `control_plane_name`, `region` and `spat_token` as arguments.
- Strips the `https://` prefix from `control_plane_endpoint` for use in Helm configuration.

## Prerequisites:
- **Helm**: Make sure Helm is installed and configured. You can install Helm by following the [official instructions](https://helm.sh/docs/intro/install/).
- **jq**: The script uses `jq` to parse JSON responses. You can install `jq` by running:
  ```
  sudo apt-get install jq
  ```

## Usage 
### Step 1: Clone the repository or download the script

````
git clone git@github.com:Kong/edu-kong-enablement.git
cd edu-kong-enablement/04-dataplane-setup/konnect/automation
````


### Step 2: Run the script

The script requires two arguments:

- Control Plane Name: The Name of the control plane you wish to query.
- Region: The Region where you want to deploy the Data Plane.
- spat Token: The token for authentication with the Kong API.

To run the script, use the following syntax:

```
./deployGateway.sh <control_plane_name> <region> <spat_token>
```

### Step 3: Helm Installation
The script will:

- Fetch the control_plane_endpoint, telemetry_endpoint and control_plane_id values.
- Uploads the certificate on Control Plane for securing ethe communication
- Install or upgrade the Kong Helm chart with the appropriate configuration.

Make sure to replace the placeholders in the script for:

<your-helm-release>: Your Helm release name.
<your-namespace>: The Kubernetes namespace where the Kong chart is deployed.
Customizing the Helm Command:
The script runs the following Helm command:

```
helm upgrade --install <your-helm-release> kong/kong \
  --set env.cluster_control_plane=$control_plane_endpoint:443 \
  --set env.cluster_server_name=$control_plane_endpoint \
  --set env.cluster_telemetry_endpoint=$telemetry_endpoint:443 \
  --set env.cluster_telemetry_server_name=$telemetry_endpoint \
  --namespace <your-namespace> --values ./values.yaml
```
You can customize the Helm parameters by modifying the script directly or by passing additional options in the Helm command as needed.

## Output:
The script will display the fetched control_plane_endpoint and telemetry_endpoint before performing the Helm upgrade/install. For example:

```
Control Plane Endpoint: mycluster.us.cp0.konghq.com:443
Telemetry Endpoint: telemetry.us.cp0.konghq.com
```

If the Helm upgrade/install is successful, you'll see:

```
Kong Helm chart upgraded successfully with the fetched endpoints.
If there are any errors in the process, the script will notify you accordingly.
```
