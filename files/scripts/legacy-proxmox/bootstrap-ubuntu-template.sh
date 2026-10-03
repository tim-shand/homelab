#!/usr/bin/env bash
# Use env to find bash, making the script portable across different systems.

set -e # Exit immediately if any command returns a non-zero status.

# ===================================================== #
# Utility: Proxmox Prep - Ubuntu Cloud-Init Template
# ===================================================== #

# DESCRIPTION:
# This bash script will download the latest cloud-init image of Ubuntu Server.  
# In addition, this script will also:
# - Install the 'qemu-guest-agent' package within the cloud-init image.
# - Set the default root password as defined by provided variable.
# - Expand the file system to 32 GB total.
# - Create a VM within Proxmox.
# - Convert the VM to a template.

# NOTE: 
# Requires administrator (sudo) privileges on Proxmox host to run.

# ------------------------------------------------------- #
# VARIABLES
# ------------------------------------------------------- #

# Proxmox Nodes
PROXMOX_NODES=("10.0.10.1" "10.0.10.2" "10.0.10.3") # List of Proxmox node IPs to create template on.
PROXMOX_USER="root" # User account for accessing Proxmox.

# OS image source.
DIST_NAME="resolute"

# Template details.
TEMPLATE_ID=9000 # Starting template ID for Proxmox.
TEMPLATE_NAME="ztmp-ubuntu-server-${DIST_NAME}" # Template name used in Proxmox.
DEFAULT_PW="ChangeMe123!" # Default root password for VM.

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

# Function: Download and prepare OS image.
prep_ubuntu_image(){
    local DIST="$1"
    local TEMPLATE_ID="$2"
    local DEFAULT_PW="$3"
    local IMG_FILE="${DIST}-server-cloudimg-amd64.img" # Image name.
    local IMG_URL="https://cloud-images.ubuntu.com/${DIST}/current/${IMG_FILE}" # Image source URL.
    local TEMPLATE_NAME="ztmp-ubuntu-server-${DIST}" # Template name used in Proxmox.
    local EXP_FS="32G"
    local REQUIRED_PACKAGES="curl libguestfs-tools" # List of required packages to install on host executing this script.
    local DST_PATH="/var/lib/vz/template/iso" # Final destination path for image file.

    apt update -y && apt install "${REQUIRED_PACKAGES}" -y &> /dev/null # Update Proxmox host apt repository and install required packages.
    curl -fL -o "${IMG_FILE}" "${IMG_URL}" # Download Image using Curl (-f = fail on HTTP errors, -L follow redirects).

    # Run provisioning prep tasks: Expand file system, install guest agent, set root password.
    if [ ! -f "${IMG_FILE}" ]; then
        echo "ERROR: Image file is not present. Abort."
        return 1
    else
        echo "- Image file present. Begin modifications."
        echo "- Expanding file system (${EXP_FS})..."
        qemu-img resize "${IMG_FILE}" "${EXP_FS}" &> /dev/null
        echo "- Installing Qemu Guest agent..."
        virt-customize -a "${IMG_FILE}" --install qemu-guest-agent &> /dev/null
        virt-customize -a "${IMG_FILE}" --root-password password:"${DEFAULT_PW}" &> /dev/null
        echo "- Customizations complete."
        echo "- Moving image file to Proxmox image directory (${DST_PATH}/)."
        mv -f "${IMG_FILE}" "${DST_PATH}/${IMG_FILE}" &> /dev/null

        # Build VM Template.
        qm create "${TEMPLATE_ID}" --name "${TEMPLATE_NAME}" \
            --ostype l26 --agent 1 --cpu host --sockets 1 --cores 2 --memory 1024 --balloon 0 \
            --bios seabios --boot order=scsi0 --scsihw virtio-scsi-pci \
            --scsi0 local-lvm:0,import-from="${DST_PATH}/${IMG_FILE}",backup=0,cache=writeback,discard=on \
            --scsi1 local-lvm:cloudinit --vga virtio --net0 virtio,bridge=vmbr0

        # Check VM creation status.
        if ! qm status "${TEMPLATE_ID}" | grep -q "status:"; then
            return 1 # Failed
        else
            echo "- Converting VM to template..."
            if ! qm template "${TEMPLATE_ID}"; then
                return 1 # Failed
            fi
        fi
    fi
}

# ------------------------------------------------------- #
# MAIN
# ------------------------------------------------------- #

echo -e "${BLUE}"
echo -e "# ======================================= #${NC}"
echo -e "         Proxmox Template Script ${BLUE}"
echo -e "# ======================================= #${NC}"
echo
log_info "Proxmox Cluster Node: ${PROXMOX_NODES[0]}"
echo

# Download Ubuntu cloud image.
log_info "Downloading distribution (${DIST_NAME})..."
if ! exec_proxmox prep_ubuntu_image "${DIST_NAME} ${TEMPLATE_ID} ${DEFAULT_PW}"; then
    log_fail "Failed to configure OS image for '${DIST_NAME}'. Abort."
    exit 1
else
    log_pass "Successfully configured OS image for '${DIST_NAME}'."
fi

echo
echo -e "${BLUE}# =======${NC} COMPLETE!!! ${BLUE}======= #${NC}"
echo
