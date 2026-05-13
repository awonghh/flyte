#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Require at least two arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <python-file> <workflow-name>"
    exit 1
fi

# Ensure jq is installed for parsing the JSON output
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is not installed. Please run 'sudo apt-get install jq' to install it."
    exit 1
fi

echo "Fetching active AWS credentials..."
# Extract the current active credentials from the AWS CLI
CREDS=$(aws configure export-credentials)

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

pyflyte run --remote -p flytesnacks -d development \
  --env AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  --env AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  --env AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN" \
    --env AWS_DEFAULT_REGION="us-east-1" \
    "$@"