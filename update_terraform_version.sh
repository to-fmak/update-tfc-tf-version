#!/bin/bash

# Check if the required arguments are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <organization_name> <terraform_version>"
  exit 1
fi

# Set variables
TFC_ORG="$1"
TF_VERSION="$2"
TFC_TOKEN_FILE=".tfc_token"
TFC_WORKSPACES_FILE="workspaces"

# Check if token and workspace files exist
if [ ! -f "$TFC_TOKEN_FILE" ]; then
  echo "Error: Token file '$TFC_TOKEN_FILE' not found."
  exit 1
fi

if [ ! -f "$TFC_WORKSPACES_FILE" ]; then
  echo "Error: Workspaces file '$TFC_WORKSPACES_FILE' not found."
  exit 1
fi

# Read the API token from the token file
TFC_TOKEN=$(cat "$TFC_TOKEN_FILE")

# Loop through each workspace and update the Terraform version
while IFS= read -r TFC_WORKSPACE; do
  # Skip empty lines
  if [ -z "$TFC_WORKSPACE" ]; then
    continue
  fi

  echo "Updating workspace: $TFC_WORKSPACE"

  # Retrieve the workspace ID
  TFC_WORKSPACE_ID=$(curl \
    --silent \
    --header "Authorization: Bearer $TFC_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    --request GET \
    https://app.terraform.io/api/v2/organizations/$TFC_ORG/workspaces/$TFC_WORKSPACE | jq -r '.data.id' 2>/dev/null)

  # Check if the workspace ID was retrieved successfully
  if [ -z "$TFC_WORKSPACE_ID" ]; then
    echo "Error: Failed to retrieve workspace ID for '$TFC_WORKSPACE'."
    continue
  fi

  # Update the Terraform version for the workspace
  STATUS_CODE=$(curl \
    --silent \
    --output /dev/null \
    --write-out "%{http_code}" \
    --header "Authorization: Bearer $TFC_TOKEN" \
    --header "Content-Type: application/vnd.api+json" \
    --request PATCH \
    --data '{
      "data": {
        "type": "workspaces",
        "id": "'"$TFC_WORKSPACE_ID"'",
        "attributes": {
          "terraform_version": "'"$TF_VERSION"'"
        }
      }
    }' \
    https://app.terraform.io/api/v2/workspaces/$TFC_WORKSPACE_ID 2>/dev/null)

  # Check if the update was successful
  if [ "$STATUS_CODE" -eq 200 ]; then
    echo "Terraform version updated to $TF_VERSION for workspace $TFC_WORKSPACE successfully."
  else
    echo "Failed to update Terraform version for workspace $TFC_WORKSPACE."
  fi

done < "$TFC_WORKSPACES_FILE"
