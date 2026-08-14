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
# - Prepares a new Proxmox cluster environment for management via automation tools.
# - Run once per cluster. Safe to re-run again as all steps are idempotent.
# ACTIONS:
# - User Management:
#   - Generates SSH key-pair for Ansible service account.
#   - Creates a new Proxmox user group for IaC service accounts.
#   - Creates dedicated service accounts (Terraform, Ansible) in Proxmox with API tokens.
# USAGE:
# - Execute locally from system with SSH access to Proxmox hosts.
# ./bootstrap-proxmox.sh
# ====================================================================================== #

# ------------------------------------------------------- #
# VARIABLES
# ------------------------------------------------------- #

# Proxmox Nodes
PROXMOX_NODES=("10.0.10.1" "10.0.10.2" "10.0.10.3")
PROXMOX_USER="root"

# User Management
GROUP_NAME="priv-iac-service-accounts" # Name of Proxmox group for service accounts.
GROUP_COMMENT="Privileged: IaC Service Accounts" # Description shown in the Proxmox UI.
GROUP_ROLE="Administrator" # Name of the built-in role to use for group permissions.
USER_TERRAFORM="svc-terraform@pve" # User account used to generate the API user in Proxmox.
USER_TERRAFORM_COMMENT="Service Account: Terraform"
USER_ANSIBLE="svc-ansible@pam" # User account name for Ansible. Also used to generate SSH key file names.
USER_ANSIBLE_COMMENT="Service Account: Ansible"

# Define colour variables.
RED="\e[31m"
YELLOW="\e[33m"
GREEN="\e[32m"
BLUE="\e[36m"
NC="\e[0m"
PASS="\u2713"
FAIL="\u2717"
SKIP="\u2212"

# ------------------------------------------------------- #
# FUNCTIONS
# ------------------------------------------------------- #

# Function: Terminal logging to add some visual pizazz.
log_info() { echo -e "${BLUE}[*] $1 ${NC}"; }
log_fail() { echo -e "${RED}[${FAIL}] $1 ${NC}"; }
log_skip() { echo -e "${YELLOW}[${SKIP}] $1 ${NC}"; }
log_pass() { echo -e "${GREEN}[${PASS}] $1 ${NC}"; }

# Function: Configure Proxmox service account group, user and API token.
proxmox_config_service_accounts(){
    local GROUP="$1"
    local GROUP_COMMENT="$2"
    local GROUP_ROLE="$3"
    shift 3
    local USER_LIST=("$@") # Take the fixed args positionally, shift, and let everything remaining become the array via "$@".
    local TOKEN="api"

    # Create group and add role permissions.
    echo "*** Configuring Group: ${GROUP}"
    pveum group add "${GROUP}" --comment "${GROUP_COMMENT}" &> /dev/null
    pveum aclmod "/" --group "${GROUP}" --role "${GROUP_ROLE}" &> /dev/null
    # Output all groups as JSON format. Use grep -q to search silently for existing match.
    if ! pveum group list --output-format json | grep -q "\"${GROUP}\""; then
        echo "ERROR: Failed to configure group (${GROUP}). Abort."
        return 1 # Group does not exist (failed). Exit.
    fi

    for USER in "${USER_LIST[@]}"; do
        echo "*** Configuring Account: ${USER}"
        pveum user add "${USER}" --comment "Service Account: ${USER%%@*}" &> /dev/null # Create user, suppress warnings.
        pveum user modify "${USER}" --group "${GROUP}" &> /dev/null # Assign the user to the group, inherits the groups ACL and role.
        if ! pveum user list --output-format json | grep -q "\"${USER}\""; then
            echo "ERROR: Failed to configure user (${USER}). Abort."
            return 1 # User does not exist (failed).
        fi
        
        # Delete existing user API token where name is the same, and re-create it.
        pveum user token delete "${USER}" "${TOKEN}" &> /dev/null # Send to null to avoid error messages if not exist.
        pveum user token add "${USER}" "${TOKEN}" --comment "API Token: $(date +%Y%m%d%H%M%S)" --privsep 0
        if ! pveum user token list "${USER}" --output-format json 2>/dev/null | grep -q "\"${TOKEN}\""; then
            echo "ERROR: Failed to configure user token (${TOKEN}). Abort."
            return 1 # API token does not exist (failed).
        fi
    done
    return 0
}

# Function: Create local Ansible service account on a Proxmox node and install SSH public key.
# Lock password login (key-only auth), and grant passwordless sudo.
proxmox_create_local_account(){
    local USER="$1"
    local PUBKEY="$2"
    local SSH_DIR="/home/${USER}/.ssh"
    local AUTH_KEYS="${SSH_DIR}/authorized_keys"
    local SUDOERS_FILE="/etc/sudoers.d/${USER}"

    # Ensure `sudo` package is installed.
    apt install -y sudo &>/dev/null

    # if user does not already exist, create.
    if ! id "${USER}" &>/dev/null; then
        rm -rf /home/"${USER}" &>/dev/null # Force remove any old remaining dirs.
        useradd -m -s /bin/bash "${USER}" # Create home dir and set shell.
    fi

    mkdir -p "${SSH_DIR}" # Create SSH directory in home path.
    touch "${AUTH_KEYS}" # Create file for authorised keys.
    grep -qxF "${PUBKEY}" "${AUTH_KEYS}" || echo "${PUBKEY}" >> "${AUTH_KEYS}"
    chown -R "${USER}:${USER}" "${SSH_DIR}" # Change owner of directory to user.
    chmod 700 "${SSH_DIR}" # Owner get read, write, execute.
    chmod 600 "${AUTH_KEYS}" # Owner gets read, write.
    usermod -L "${USER}" # Lock out password auth (so key only).
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" > "${SUDOERS_FILE}" # Enable passwordless sudo.

    # Files under /etc/sudoers.d/ are checked by sudo before being trusted. If a file is group or world writable, sudo refuses to read it and logs warning.
    chmod 440 "${SUDOERS_FILE}" # root can read, group can read, no write for anyone, no execute, and no permissions at all for "other".
    visudo -cf "${SUDOERS_FILE}" # Catches syntax errors in the file content.
}

# Function: Execute remote commands on a single Proxmox node, passing in function and parameters.
exec_proxmox(){
    local RC=0 # Return code var.
    local FUNC="$1" # Pass in function to execute remotely.
    local PARAMS="$2" # Pass in the function parameters.
    # Use `declare -f` to serialize the function into a string to pass it to the remote server.
    ssh "${PROXMOX_USER}@${PROXMOX_NODES[0]}" \
        "$(declare -f ${FUNC}); ${FUNC} ${PARAMS}" || RC=$?
    return "${RC}"
}

# Function: Execute remote commands on all Proxmox nodes, passing in function and parameters.
exec_proxmox_all(){
    local RC=0 # Return code var.
    local FUNC="$1" # Pass in function to execute remotely.
    local PARAMS="$2" # Pass in the function parameters.
    for NODE in "${PROXMOX_NODES[@]}"; do
        # Use `declare -f` to serialize the function into a string to pass it to the remote server.
        if ! ssh "${PROXMOX_USER}@${NODE}" "$(declare -f ${FUNC}); ${FUNC} ${PARAMS}"; then
            return 1
        fi
    done
}

# Function: Generate SSH key-pair for provided user (no passphrase, automation account).
generate_ssh_keys() {
    local USER="$1" # Pass the first parameter into local variable.
    local KEY_NAME="${USER}.ssh"
    if [ ! -f "${KEY_NAME}" ]; then
        ssh-keygen -q -t ed25519 -N "" -C "${USER}" -f "$(pwd)/${KEY_NAME}"
        if [ ! -f "$(pwd)/${KEY_NAME}" ]; then
            log_fail "Failed to generate SSH key-pair for user '${USER}'. Abort."
        else
            log_pass "SSH key-pair generated for user '${USER}'."
        fi
    else
        log_skip "SSH key-pair for user '${USER}' already present. Skip."
        echo "    - Private Key:  $(pwd)/${KEY_NAME}"
        echo "    - Public Key:   $(pwd)/${KEY_NAME}.pub"
    fi
}

# ------------------------------------------------------- #
# MAIN
# ------------------------------------------------------- #

echo -e "${BLUE}"
echo -e "# ======================================= #${NC}"
echo -e "         Proxmox Bootstrap Script ${BLUE}"
echo -e "# ======================================= #${NC}"
echo
log_info "Proxmox Cluster Nodes: ${PROXMOX_NODES[*]}"
echo

ANSIBLE_LOCAL_USER="${USER_ANSIBLE%%@*}"
ANSIBLE_PUBKEY=$(cat "$(pwd)/${ANSIBLE_LOCAL_USER}.ssh.pub")

# Generate SSH key-pair for Ansible service account only. Terraform doesn't need local access.
generate_ssh_keys "${ANSIBLE_LOCAL_USER}" # Use '%%<CHAR>*' to remove anything after <CHAR> (such as @pam or @pve).
echo

# Create local Ansible service account on each Proxmox node.
log_info "Configuring local service account on all Proxmox nodes..."
if ! exec_proxmox_all proxmox_create_local_account \
    "'${ANSIBLE_LOCAL_USER}' '${ANSIBLE_PUBKEY}'"; then
    log_fail "Failed local node configuration for Ansible account."
    exit 1
else
    log_pass "Local node configuration for Ansible account succeeded."
fi
echo

# Configure Proxmox service account group, accounts and API tokens.
log_info "Connecting to first node in Proxmox cluster (${PROXMOX_NODES[0]})..."
if ! exec_proxmox proxmox_config_service_accounts \
    "'${GROUP_NAME}' '${GROUP_COMMENT}' '${GROUP_ROLE}' '${USER_TERRAFORM}' '${USER_ANSIBLE}'"; then
    log_fail "Failed service account configuration in Proxmox."
    exit 1
else
    log_pass "Proxmox service account configuration succeeded."
fi

echo
echo -e "${BLUE}# =======${NC} COMPLETE!!! ${BLUE}======= #${NC}"
echo
