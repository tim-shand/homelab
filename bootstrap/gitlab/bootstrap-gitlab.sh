#!/usr/bin/env bash
# Use env to find bash, making the script portable across different systems.

set -euo pipefail
# -e  Exit immediately if any command returns a non-zero status.
# -u  Treat unset variables as errors rather than empty strings.
# -o  If any command in a pipe fails, the whole pipe returns failure.

# ===================================================== #
# Bootstrap: GitLab CE Server
# ===================================================== #

# DESCRIPTION:
# This script performs the following tasks:
# - Executes Terraform to deploy (or destroy) a Proxmox VM.
# - Executes an Ansible playbook to install GitLab CE.
# - Configures the GitLab instance using Ansible.

# ------------------------------------------------------- #
# VARIABLES
# ------------------------------------------------------- #

DIR_SSH_KEYS="./ssh_keys"
DIR_TERRAFORM="./terraform"
DIR_TFVARS_GLOBAL="../../../variables/global-proxmox.tfvars"
DIR_ANSIBLE="./ansible"
REQUIRED_APPS=("terraform" "ansible" "az")
REQUIRED_FILES_TERRAFORM=("backend.tf" "terraform.tfvars" "${DIR_TFVARS_GLOBAL}")
REQUIRED_FILES_ANSIBLE=("inventory.ini" "vars.yaml")
# Define colour variables.
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
NC="\e[0m"
PASS="\xE2\x9C\x93"
FAIL="\xE2\x9C\x98"

# ------------------------------------------------------- #
# FUNCTIONS
# ------------------------------------------------------- #

preflight_checks(){
    # Confirm Terraform and Ansible are installed.
    for APP in "${REQUIRED_APPS[@]}"; do
        if [ ! command -v "${APP}" &> /dev/null ]; then
            printf "${RED}${FAIL} ERROR:${NC} Required application (${APP}) is missing! Please install and try again.\n"
            exit 1
        fi
    done
    printf "${GREEN}${PASS} PASS:${NC} Required applications are installed.\n"

    # Check for required Terraform files.
    for T_FILE in "${REQUIRED_FILES_TERRAFORM[@]}"; do
        if [ ! -f "${DIR_TERRAFORM}/${T_FILE}" ]; then
            printf "${RED}${FAIL} ERROR:${NC} Required Terraform file (${T_FILE}) is missing! Abort.\n"
            exit 1
        fi
    done
    printf "${GREEN}${PASS} PASS:${NC} Required Terraform files are present.\n"

    # Check for required Ansible files.
    for A_FILE in "${REQUIRED_FILES_ANSIBLE[@]}"; do
        if [ ! -f "${DIR_ANSIBLE}/${A_FILE}" ]; then
            printf "${RED}${FAIL} ERROR:${NC} Required Ansible file (${A_FILE}) is missing! Abort.\n"
            exit 1
        fi
    done
    printf "${GREEN}${PASS} PASS:${NC} Required Ansible files are present.\n"
}

# Using function for `run_tf` centralises the pattern so not repeating conditionals.
run_tf() {
    local cmd="$1"
    shift
    if terraform -chdir="$DIR_TERRAFORM" "$cmd" "$@"; then
        printf "${GREEN}${PASS} PASS:${NC} Terraform ${cmd} succeeded.\n"
    else
        local return_code=$?
        printf "${RED}${FAIL} ERROR:${NC} Terraform ${cmd} failed (exit code ${return_code}).\n"
        exit "$return_code"
    fi
}

# ------------------------------------------------------- #
# MAIN
# ------------------------------------------------------- #

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
            echo "ERROR: Unknown option: $1"
            exit 1
            ;;
    esac # Closes the case statement (case spelled backwards :D).
done

printf -- "--------------------------------------------------- \n"
printf "Bootstrap: GitLab CE Server (Terraform, Ansible)    \n"
printf -- "--------------------------------------------------- \n"

if $DESTROY; then
    printf "* RUN MODE:${RED} [-] Destroy${NC}\n"
else
    printf "* RUN MODE:${GREEN} [+] Deploy${NC}\n"
fi

# Pre-flight Checks
printf "\n${CYAN}* Performing pre-flight checks...${NC}\n"
preflight_checks

# Setup Terraform (using function, no need to pass working dir).
run_tf init -upgrade

# Final warning for destroy mode.
if [ "$DESTROY" = true ]; then
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
    # Execute Terraform destroy run.
    run_tf fmt
    run_tf validate
    run_tf apply -var-file="${DIR_TFVARS_GLOBAL}"

    # Allow time for the new VM to come online.
    sleep 15

    # Pass the VMs IP address from Terraform to Ansible.
    VM_IP=$(run_tf output ipv4_address) # Pipe output of command into variable.
    VM_UN=$(run_tf output -raw default_user) # Pipe output of command into variable.
    VM_PW=$(run_tf output -raw default_pass) # Pipe output of command into variable.
    

    # Execute Ansible playbook to install GitLab.
    #ansible-playbook -i $VM_IP, $DIR_ANSIBLE/testing.yml -e "ansible_user=your_username ansible_password=your_password"
fi
