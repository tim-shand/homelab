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

DIR_TERRAFORM="./terraform"
DIR_ANSIBLE="./ansible"
DIR_SSH_KEYS="./ssh_keys"

