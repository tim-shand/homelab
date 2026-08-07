#!/usr/bin/env bash
# Use env to find bash, making the script portable across different system layouts.

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

# List of Ubuntu distributions to loop and create templates for.
UBUNTU_DIST_NAMES=("noble" "resolute") # Ubuntu distribution code names.
TEMPLATE_ID_BASE=9000 # Starting template ID for Proxmox.
REQUIRED_PACKAGES="git curl libguestfs-tools" # List of required packages to install on host executing this script.
DST_PATH=/var/lib/vz/template/iso # Final destination path for image file.
EXP_FS="32G" # String value for desired file system size during expansion.
DEFAULT_PW="changeme123!" # Default root password for VM.
COUNTER=0 # Counter used to iterate the VM ID.

# ------------------------------------------------------- #
# FUNCTIONS
# ------------------------------------------------------- #

download_os_image(){
    curl -fL -o "$IMG_FILE" "$IMG_URL" # Download Image using Curl (-f = fail on HTTP errors, -L follow redirects).
    # Run provisioning prep tasks: Expand file system, install guest agent, set root password.
    if [ -f "$IMG_FILE" ]; then
        echo "INFO: Image file present. Begin modifications."
        echo "- Expanding file system ($EXP_FS)..."
        qemu-img resize "$IMG_FILE" "$EXP_FS" &> /dev/null
        echo "- Installing Qemu Guest agent..."
        virt-customize -a $IMG_FILE --install qemu-guest-agent &> /dev/null
        virt-customize -a $IMG_FILE --root-password password:$DEFAULT_PW &> /dev/null
        echo "INFO: Customizations complete."
        echo "INFO: Moving image file to Proxmox image directory ($DST_PATH/)."
        mv -f "$IMG_FILE" "$DST_PATH/$IMG_FILE" &> /dev/null
    else
        echo "ERROR: Image file is not present. Abort."
        return 1
    fi
}

build_vm_template(){
    if [ -f "$DST_PATH/$IMG_FILE" ]; then
        echo "INFO: Creating VM for template..."
        VM_ID=$((TEMPLATE_ID_BASE + COUNTER))
        qm create $VM_ID --name "$TEMPLATE_NAME" \
            --ostype l26 --agent 1 --cpu host --sockets 1 --cores 2 --memory 1024 --balloon 0 \
            --bios seabios --boot order=scsi0 --scsihw virtio-scsi-pci \
            --scsi0 local-lvm:0,import-from="$DST_PATH/$IMG_FILE",backup=0,cache=writeback,discard=on \
            --scsi1 local-lvm:cloudinit --vga virtio --net0 virtio,bridge=vmbr0
        if qm status $VM_ID | grep -q "status:"; then
            echo "INFO: Converting VM to template..."
            if qm template "$VM_ID"; then
                echo "Template conversion successful."
            else
                echo "Template conversion failed."
            fi
        else
            echo "ERROR: Failed to provision VM template. Abort."
        fi
    else
        echo "ERROR: Image file is not present in destination. Abort."
        return 1
    fi
}

# ------------------------------------------------------- #
# MAIN
# ------------------------------------------------------- #

# Update Proxmox host apt repository and install required packages.
echo "INFO: Updating repository and installing required packages..."
apt update -y && apt install $REQUIRED_PACKAGES -y &> /dev/null

# Loop through each distro codename to create Proxmox template.
for DIST in "${UBUNTU_DIST_NAMES[@]}"; do
    echo "INFO: Processing distribution: $DIST"
    echo "Iteration: COUNTER=$COUNTER DIST=$DIST"

    IMG_FILE="${DIST}-server-cloudimg-amd64.img" # Image name.
    IMG_URL="https://cloud-images.ubuntu.com/${DIST}/current/${IMG_FILE}" # Image source URL.
    TEMPLATE_NAME="ztmp-ubuntu-server-${DIST}" # Template name used in Proxmox.

    echo "INFO: Downloading image file: $IMG_URL"
    download_os_image

    sleep 5

    echo "INFO: Building Proxmox VM template..."
    build_vm_template || continue

    COUNTER=$((COUNTER + 1))
done

echo "--------- COMPLETE ---------"
