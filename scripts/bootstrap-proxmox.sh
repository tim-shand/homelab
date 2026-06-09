#!/usr/bin/env bash
# This script is used to bootstrap a Proxmox VE server for IaC.
# It performs the following tasks:
# 1. Updates the package list and upgrades existing packages.
# 2. Creates a new group for service accounts.
# 3. Assigns the defined role to the new group.
# 4. Creates a new user and adds to the new group.
# 5. Creates an API token for the user.

set -euo pipefail

# Update package list and upgrade existing packages
echo "Updating package list and upgrading existing packages..."
apt update && apt upgrade -y

# Configuration ----------------------------------------------------------- #

# Role to use for group role assignment.
ROLE_NAME="Administrator" # Built-in role with full permissions (adjust if you want more restrictive permissions).

# User and group configuration.
USER_ID="svc-terraform@pve"
USER_DESC="Service Account: IaC (Terraform)"
GROUP_ID="svc-accounts"
GROUP_DESC="Custom Group: Service Accounts"
TOKEN_ID="api"
TOKEN_DESC="API token for IaC management (created by bootstrap script)."

# Create the group if it doesn't exist and add the user to the group.
echo "[1/5] Creating new group: ${GROUP_ID}..."
pveum group add "${GROUP_ID}" --comment "${GROUP_DESC}" 2>/dev/null || echo "WARN: Group already exists, skipping."

# Add role to new group.
echo "[2/5] Adding role '${ROLE_NAME}' to group '${GROUP_ID}'"
pveum acl modify / -group "${GROUP_ID}" -role "${ROLE_NAME}"

# Create the service account user (no password, token auth only).
echo "[3/5] Creating new user: ${USER_ID}..."
pveum user add "${USER_ID}" --comment "${USER_DESC}" 2>/dev/null || echo "WARN: User already exists, skipping."

# Add user to group.
echo "[4/5] Adding user '${USER_ID}' to group '${GROUP_ID}'"
pveum usermod "${USER_ID}" -group "${GROUP_ID}"

# Create API token for the user.
echo "[5/5] Creating API token for user '${USER_ID}'"
echo ""
echo "=== TOKEN OUTPUT: COPY THIS NOW ==="
echo "Store the token secret in GitHub Actions Secrets or password manager."
echo "It will NOT be shown again."
echo ""
pveum user token add "${USER_ID}" "${TOKEN_ID}" --privsep 0 --comment "${TOKEN_DESC}"

echo "=== Bootstrap Complete! ==="
echo "API token created for user '${USER_ID}' with token ID '${TOKEN_ID}'."
echo "Use the following values to configure GitHub Actions Secrets:"
echo "- TF_VAR_proxmox_api_token_id  = ${USER_ID}!${TOKEN_ID}"
echo "- TF_VAR_proxmox_api_token_secret = <value from above>"
