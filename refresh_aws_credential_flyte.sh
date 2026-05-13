#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure jq is installed for parsing the JSON output
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please run 'sudo apt-get install jq' to install it."
    exit 1
fi

echo "Fetching active AWS credentials..."
# Extract the current active credentials from the AWS CLI
CREDS=$(aws configure export-credentials --profile RnDPowerUserAccess)

# Parse the JSON output into variables
export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.SessionToken')

# Verify we actually got a token
if [ "$AWS_SESSION_TOKEN" == "null" ] || [ -z "$AWS_SESSION_TOKEN" ]; then
    echo "Error: Failed to find a temporary Session Token. Are you logged in?"
    exit 1
fi

echo "Successfully retrieved keys! (Access Key: ${AWS_ACCESS_KEY_ID:0:8}...)"
echo "Injecting credentials into the Flyte backend..."

# Force the new variables into the Deployment
kubectl set env deployment/flyte-backend-flyte-binary -n flyte \
  AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"

echo "Waiting for the new pod to roll out..."
# Watch the deployment until the new pod is fully running
kubectl rollout status deployment/flyte-backend-flyte-binary -n flyte

echo "✅ Keys refreshed! You can now start your port-forward command."