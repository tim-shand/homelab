#!/usr/bin/env bash
# Use env to find bash, making the script portable across different systems.

set -euo pipefail
# -e  Exit immediately if any command returns a non-zero status.
# -u  Treat unset variables as errors rather than empty strings.
# -o  If any command in a pipe fails, the whole pipe returns failure.



for USER in "${USER_IDS[@]}"; do
    if id "${USER}" &>/dev/null; then # Check if user already present and skip.
        echo "WARNING: User already exists. Skipping..."
    else
        echo "INFO: Processing User: ${USER}"
        #useradd -m -s /bin/bash "${USER}" # Create a dedicated sudo-enabled user on each Proxmox host.
        # Grant passwordless sudo privileges to the service account user.
        #echo "${USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
    fi
done
