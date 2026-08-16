#!/usr/bin/env bash
# Use env to find bash, making the script portable across different systems.

set -euo pipefail
# -e  Exit immediately if any command returns a non-zero status.
# -u  Treat unset variables as errors rather than empty strings.
# -o  If any command in a pipe fails, the whole pipe returns failure.

# ===================================================== #
# Bootstrap: Gitea Server
# ===================================================== #

# DESCRIPTION:
# This script performs the following tasks:
# - Executes Terraform to deploy (or destroy) a Proxmox VM from template.
# - Executes an Ansible playbook to install Gitea on VM.

# ------------------------------------------------------- #
# VARIABLES
# ------------------------------------------------------- #

DIR_SSH_KEYS="../../files/ssh_keys"
DIR_TERRAFORM="./terraform"
DIR_TFVARS_GLOBAL="../../../variables/global-proxmox.tfvars"
DIR_ANSIBLE="./ansible"
REQUIRED_APPS=("terraform" "ansible" "az")
REQUIRED_FILES_TERRAFORM=("backend.tf" "terraform.tfvars")

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

preflight_checks(){
    # Confirm Terraform and Ansible are installed.
    for APP in "${REQUIRED_APPS[@]}"; do
        if [ ! command -v "${APP}" &> /dev/null ]; then
            log_fail "Required application (${APP}) is missing! Please install and try again."
            return 1
        fi
    done
    log_pass "All required applications are installed."
}

# Using function for `run_tf` centralises the pattern so not repeating conditionals.
run_tf() {
    local cmd="$1"
    shift
    if ! terraform -chdir="${DIR_TERRAFORM}" "${cmd}" "$@"; then
        local return_code=$?
        log_fail "Terraform ${cmd} failed (exit code ${return_code})."
        return 1
    fi
}

# ------------------------------------------------------- #
# MAIN
# ------------------------------------------------------- #

echo -e "${BLUE}"
echo -e "# ======================================= #${NC}"
echo -e "       Bootstrap Script: Gitea Server ${BLUE}"
echo -e "# ======================================= #${NC}"
echo

# Flag to set destroy mode.
# Starts a loop that continues as long as there are unprocessed positional parameters.
DESTROY=false
while [[ $# -gt 0 ]]; do # `$#`` is a special variable holding the count of positional parameters.
    case "$1" in
        --destroy)
            DESTROY=true
            shift # Shift through arguments, `$#`` decreases each time, so the loop terminates once all arguments have been consumed.
            ;; # Terminates this case branch (equivalent to break in a C-style switch).
        *) # Catch-all/default pattern that matches anything not caught by an earlier branch.
            log_fail "ERROR: Unknown option: $1"
            exit 1
            ;;
    esac # Closes the case statement (case spelled backwards :D).
done

if $DESTROY; then
    printf "* RUN MODE:${RED} [-] Destroy${NC}\n"
else
    printf "* RUN MODE:${GREEN} [+] Deploy${NC}\n"
fi

# Pre-flight Checks
log_info "Performing pre-flight checks..."
preflight_checks

# Setup Terraform (using function, no need to pass working dir).
log_info "Configuring Terraform......"
run_tf init -upgrade

# Final warning for destroy mode.
if [ "${DESTROY}" = true ]; then
    printf "${RED}!!! WARNING !!! ${NC}\n"
    printf "Run mode is set to ${RED}DESTROY! ${NC}\n"
    printf "All resources previously deployed will be removed.\n"
    while true; do
        read -p "Do you want to continue? (y/n): " yn
        case $yn in
            [Yy]* ) echo "Proceeding..."; break;;
            [Nn]* ) echo "Exiting..."; exit 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done

    # Execute Terraform destroy run.
    run_tf destroy -var-file="${DIR_TFVARS_GLOBAL}"
else
    # Execute Terraform --------------------------------------------------------- #
    run_tf fmt
    run_tf validate
    run_tf apply -var-file="${DIR_TFVARS_GLOBAL}"

    # Allow time for the new VM to come online.
    sleep 1 # Change to 15 in prod.

    # Pass the VMs IP address from Terraform to Ansible.
    TF_VM_IP="$(run_tf output ipv4_address)" # Pipe output of command into variable.
    TF_VM_UN="$(run_tf output default_user)"
    VM_IP="${TF_VM_IP//\"}" # Clean up quotes from string.
    VM_UN="${TF_VM_UN//\"}" # Clean up quotes from string.
    echo
    echo "IP Address: ${VM_IP}"
    echo "Username:   ${VM_UN}"

    # SSH --------------------------------------------------------- #
    # Purge the previously stored host key from known hosts and add the new host key.
    ssh-keygen -R "${VM_IP}" &> /dev/null
    ssh-keyscan -H "${VM_IP}" >> ~/.ssh/known_hosts

    # Ansible --------------------------------------------------------- #
    log_info "Executing Ansible playbook..."
    ansible all -i "${VM_IP}," -u "${VM_UN}" --private-key="${DIR_SSH_KEYS}/${VM_UN}.ssh" -m ping
    #ansible-playbook -i "${DIR_ANSIBLE}/inventory.ini" -u "${VM_UN}" --private-key="${DIR_SSH_KEYS}/${VM_UN}.ssh" "${DIR_ANSIBLE}/gitvm_server.yml"

    echo
    echo -e "${BLUE}# =======${NC} COMPLETE!!! ${BLUE}======= #${NC}"
    echo
fi
