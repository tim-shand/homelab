#!/usr/bin/env bash
# Use env to find bash, making the script portable across different system layouts.

set -euo pipefail
# -e  Exit immediately if any command returns a non-zero status.
# -u  Treat unset variables as errors rather than empty strings.
# -o  If any command in a pipe fails, the whole pipe returns failure.

# ============================================================================= #
# Proxmox: Bootstrap Script
# Creates a service account group, role, user, and API token for Terraform (IaC).
# Run once per cluster. Safe to re-run all steps are idempotent.
#
# Usage:
#   Directly on Proxmox node:   bash bootstrap-proxmox.sh
#   Remote via SSH:              ssh root@<node-ip> 'bash -s' < bootstrap-proxmox.sh
# ============================================================================= #

# Variables ----------------------------------------------------------- #

GROUP_NAME="priv-service-accounts-iac" # Name of Proxmox group for service accounts.
GROUP_COMMENT="Privileged: Service Accounts" # Description shown in the Proxmox UI.
ROLE_NAME="IaC-Automation" # Name of the custom role to use for IaC permissions.
USER_ID="svc-iac-terraform@pve" # Proxmox user ID. Using '@pve' means a local Proxmox account, not LDAP or PAM.
USER_COMMENT="Service Account: Terraform" # Description shown in the Proxmox UI for user account.
TOKEN_NAME="token" # Name of the API token. The full token ID will be like 'username@pve!token'.
TOKEN_COMMENT="API Token: $(date +%Y%m%d)" # Description of token shown in the Proxmox UI with date stamp.

# Custom Role: Built-in 'Administrator' role has more permissions than needed, so create a custom role with only the necessary privileges.
# Principle of least privilege to reduce risk if the token is compromised. Also, 'PVEAdmin' is too light (missing sys.modify).
PRIVILEGES=(
  "Datastore.AllocateSpace"       # Create and resize disks on datastores.
  "Datastore.Audit"               # Read datastore contents and status.
  "Pool.Allocate"                 # Create and delete resource pools.
  "Pool.Audit"                    # Read pool contents and membership.
  "SDN.Allocate"                  # Create and manage SDN zones, vnets, and subnets.
  "SDN.Audit"                     # Read SDN configuration and status.
  "SDN.Use"                       # Attach VMs and containers to SDN networks.
  "Sys.Audit"                     # Read node status and logs; replaces VM.Monitor for basic QEMU monitor access.
  "Sys.Console"                   # Access node console.
  "Sys.Modify"                    # Modify node config including network and SDN apply.
  "VM.Allocate"                   # Create and delete VMs and containers.
  "VM.Audit"                      # Read VM configuration and status.
  "VM.Backup"                     # Backup and restore VMs.
  "VM.Clone"                      # Clone existing VMs and templates.
  "VM.Config.CDROM"               # Attach and detach ISO images.
  "VM.Config.CPU"                 # Modify CPU settings.
  "VM.Config.Cloudinit"           # Manage cloud-init configuration drives.
  "VM.Config.Disk"                # Add, remove, and resize disks.
  "VM.Config.HWType"              # Change hardware emulation type.
  "VM.Config.Memory"              # Modify memory allocation.
  "VM.Config.Network"             # Add and modify network interfaces.
  "VM.Config.Options"             # Modify general VM options such as boot order.
  "VM.Console"                    # Console access to VM.
  "VM.GuestAgent.Audit"           # Issue informational QEMU guest agent commands.
  "VM.Migrate"                    # Migrate VMs between nodes.
  "VM.PowerMgmt"                  # Start, stop, reset, and suspend VMs.
  "VM.Replicate"                  # Storage replication.
)

# Terminal Colours ------------------------------------------------------------ #

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No colour/plain.

# Logging Functions ------------------------------------------------------- # 

log_info()    { echo -e "${BLUE} *${NC} $1"; }
log_success() { echo -e "${GREEN} [+]${NC} $1"; }
log_skip()    { echo -e "${YELLOW} [-]${NC} $1 (already exists, skipping)."; }
log_error()   { echo -e "${RED}  [x]${NC} $1"; }

# Pre-flight Checks -------------------------------------------------------- #

# Check if script run with root privs. EUID is the effective user ID, 0 means the root user.
# The Proxmox command 'pveum' requires root privileges to manage users and tokens.
if [[ $EUID -ne 0 ]]; then
  log_error "This script must be run as root. Abort."
  exit 1
fi

# Check the target is actually a Proxmox node by confirming the 'pveum' command.
# The '-v' switch returns the path to a binary, if it exists.
if ! command -v pveum &>/dev/null; then
  log_error "Command 'pveum' not found. Target may not be Proxmox node. Abort."
  exit 1
fi

# MAIN SCRIPT ---------------------------------------------------------- #

echo ""
echo "# ============================== #"
echo "     Proxmox Bootstrap Script     "
echo "# ============================== #"
echo ""

# Service Account Group ----------------------------------------------------- #

log_info "Creating group: ${GROUP_NAME}"
# Output all groups as JSON format. Use grep -q to search silently for existing match, skip if found, create if not exists.
if pveum group list --output-format json | grep -q "\"${GROUP_NAME}\""; then
  log_skip "Group '${GROUP_NAME}'"
else
  pveum group add "${GROUP_NAME}" --comment "${GROUP_COMMENT}"
  log_success "Created group '${GROUP_NAME}'"
fi

# Custom Role --------------------------------------------------------- #

log_info "Creating role: ${ROLE_NAME}"
# IFS sets the Internal Field Separator to a comma for this subshell only.
# "${PRIVILEGES[*]}" expands array as a single string joined by IFS.
# Result is comma-separated string of privileges that pveum expects for input.
PRIV_STRING=$(IFS=, ; echo "${PRIVILEGES[*]}")

# Check if role already exists using the same JSON grep pattern.
if pveum role list --output-format json | grep -q "\"${ROLE_NAME}\""; then
  log_skip "Role '${ROLE_NAME}'"
  # If role exists, update privileges in case list has changed.
  log_info "Ensuring role privileges are up to date..."
  pveum role modify "${ROLE_NAME}" --privs "${PRIV_STRING}"
  log_success "Privileges updated!"
else
  # Creates the role with the full privilege string.
  pveum role add "${ROLE_NAME}" --privs "${PRIV_STRING}"
  log_success "Created role '${ROLE_NAME}'"
fi

# Assign Role to Group --------------------------------------------- #

log_info "Assigning role '${ROLE_NAME}' to group '${GROUP_NAME}' at /"
pveum aclmod / --group "${GROUP_NAME}" --role "${ROLE_NAME}"
log_success "ACL applied"

# Create Service Account User ---------------------------------------------------- #

log_info "Creating user: ${USER_ID}"
if pveum user list --output-format json | grep -q "\"${USER_ID}\""; then
  # Check if user already exists, skip if present.
  log_skip "User '${USER_ID}'"
else
  pveum user add "${USER_ID}" --comment "${USER_COMMENT}"
  # Creates the local Proxmox user — no password is set since login
  # will only happen via API token, not interactive session
  log_success "Created user '${USER_ID}'"
fi

# Add User to Group ------------------------------------------------------ #

# Assign the user to the group, inherits the groups ACL and role.
log_info "Adding '${USER_ID}' to group '${GROUP_NAME}'"
pveum user modify "${USER_ID}" --group "${GROUP_NAME}"
log_success "User added to group"

# API Token ----------------------------------------------------------- #

log_info "Creating API token: ${USER_ID}!${TOKEN_NAME}"
if pveum user token list "${USER_ID}" --output-format json 2>/dev/null | grep -q "\"${TOKEN_NAME}\""; then
  # Use 2>/dev/null suppresses error if user has not tokens yet, grep -q checks for token name in the JSON output.
  log_skip "Token '${TOKEN_NAME}'"
  echo ""
  echo -e "${YELLOW}Warning:${NC} Token already exists and the secret cannot be retrieved."
  # Proxmox only shows token secret at creation. No way to retrieve it again from the API or CLI.
  echo "If you have lost the secret, remove the token and re-run this script."
else
  echo ""
  echo -e "${YELLOW}Token will only be shown ONCE!! Save the token secret below. ${NC}"
  echo ""
  # Use --privsep 0 disables privilege separation, meaning the token inherits privileges assigned to the user via the group.
  pveum user token add "${USER_ID}" "${TOKEN_NAME}" --comment "${TOKEN_COMMENT}" --privsep 0
fi

# Output Summary ---------------------------------------------------------- #

echo ""
echo "Resources Configured:"
echo "- Group : ${GROUP_NAME}"
echo "- Role  : ${ROLE_NAME}"
echo "- User  : ${USER_ID}"
echo "- Token : ${USER_ID}!${TOKEN_NAME}"
echo ""
echo "Next Steps:"
echo "1. Save the above token secret to a password manager."
echo "2. Run terraform/bootstrap/gitlab to provision the GitLab LXC."
echo "3. Add the token to GitLab CI/CD variables as TF_VAR_proxmox_api_token."
echo ""
