#!/usr/bin/env bash
# Use env to find bash, making the script portable across different systems.

set -euo pipefail
# -e  Exit immediately if any command returns a non-zero status.
# -u  Treat unset variables as errors rather than empty strings.
# -o  If any command in a pipe fails, the whole pipe returns failure.

# ====================================================================================== #
# TITLE: Proxmox Bootstrap Script
# AUTHOR: Tim Shand
# DESCRIPTION: 
# - Prepares a new Proxmox environment for management via automation tools.
# - Run once per cluster. """Safe to re-run again as all steps are idempotent."""
# ACTIONS:
# - User Management:
#   - Creates a new Proxmox user group for IaC service accounts.
#   - Creates dedicated service accounts (Terraform, Ansible) in Proxmox with API tokens.
# - VM Templates:
#   - Downloads Ubuntu cloud image based on provided distro code name.
#   - Creates a VM template from downloaded image file.
# USAGE:
# - Directly Proxmox node:   bash bootstrap-proxmox.sh
# - Remote via SSH:          ssh root@proxmox-node 'bash -s' < bootstrap-proxmox.sh
# ====================================================================================== #

# ------------------------------------------------------- #
# VARIABLES
# ------------------------------------------------------- #

# Proxmox Nodes
PROXMOX_NODES=("10.0.10.1" "10.0.10.2" "10.0.10.3")
#PROXMOX_NODES=("10.0.10.1")
PROXMOX_USER="root"

# User Management
GROUP_NAME="priv-service-accounts" # Name of Proxmox group for service accounts.
GROUP_COMMENT="Privileged: Service Accounts" # Description shown in the Proxmox UI.
ROLE_NAME="Administrator" # Name of the built-in role to use for group permissions.
USER_TERRAFORM="svc-terraform@pve" # User account used to generate the API user in Proxmox.
USER_ANSIBLE="svc-ansible@pam" # User account name for Ansible. Also used to generate SSH key file names.
TOKEN_NAME="api" # Name of the API token. The full token ID will be like 'username@pve!token'.
TOKEN_COMMENT="API Token: $(date +%Y%m%d)" # Description of token shown in the Proxmox UI with date stamp.

# Define colour variables.
RED="\e[31m"
YELLOW="\e[33m"
GREEN="\e[32m"
BLUE="\e[36m"
NC="\e[0m"
PASS="\xE2\x9C\x93"
FAIL="\xE2\x9C\x98"
SKIP="\xE2\x9E\x96"

# ------------------------------------------------------- #
# FUNCTIONS
# ------------------------------------------------------- #

# Function: Terminal logging to add some visual pizazz.
log_info() { echo -e "${BLUE}*${NC} $1"; }
log_fail() { echo -e "${RED}${FAIL}${NC} $1"; }
log_skip() { echo -e "${YELLOW}${SKIP}${NC} $1"; }
log_pass() { echo -e "${GREEN}${FAIL}${NC} $1"; }

# Function: Generate SSH key-pair for provided user (no passphrase, automation account).
generate_ssh_keys() {
    local USER="$1" # Pass the first parameter into local variable.
    if [ ! -f "./ssh_${USER}" ]; then
        ssh-keygen -q -t ed25519 -N "" -C "${USER}" -f "./ssh_${USER}"
        if [ ! -f "./ssh_${USER}" ]; then
            log_fail "Failed to generate SSH key-pair for user '${USER}'. Abort."
        else
            log_pass "SSH key-pair generated for user '${USER}'."
        fi
    else
        log_pass "SSH key-pair for user '${USER}' already present."
    fi
}

# Function: Create Proxmox group for service accounts and assign role.
proxmox_create_group(){
    local GROUP="$1"
    local COMMENT="$2"
    local ROLE="$3"
    # Output all groups as JSON format. Use grep -q to search silently for existing match, skip if found, create if not exists.
    if pveum group list --output-format json | grep -q "\"${GROUP}\""; then
        return 0
    else
        pveum group add "${GROUP}" --comment "${COMMENT}"
        return 1
    fi
    # Check role permission assignments.
    pveum aclmod "/" --group "${GROUP}" --role "${ROLE}"
}

# ------------------------------------------------------- #
# MAIN
# ------------------------------------------------------- #

# - Generate SSH key-pair for Ansible service account.
# - Copy SSH key-pair to local workstation.
# - Copy SSH public key to each Proxmox node (authorized_keys) to enable Ansible to apply configuration at host level.

generate_ssh_keys "svc-ansible"

# Generate SSH key-pairs for service accounts.
#generate_ssh_keys "${USER_ANSIBLE}"

# Create dedicated service account group in Proxmox. Run on first node only (cluster wide change).
# Use `declare -f` to serialize the function into a string to pass it to the remote server.
# ssh "${PROXMOX_USER}"@"${PROXMOX_NODES[0]}" "bash -s" << EOF
# $(declare -f proxmox_create_group)
# proxmox_create_group "${GROUP_NAME}" "${GROUP_COMMENT}" "${ROLE_NAME}"
# EOF

