# ========================================================================================================== #
# Global Variables: Packer
# Description:
# - Global variable definitions for Packer.
# ========================================================================================================== #

#pve_api_packer_user # Passed in via workflow variables/secrets.
#pve_api_packer_token # Passed in via workflow variables/secrets.

vm_id = 9900
os_name = "Ubuntu"
distro_version = "26.04" # Ubuntu version number.
distro_name = "Resolute" # Ubuntu code name for the distribution.
default_password = "changeme123" # Default password for image.
pve_storage = "local-lvm" # Location for disk and cloud init storage (local-lvm, pve-zfs-pool).
vm_bridge = "vmbr1"
vm_vlan_tag = "20"
iso_checksum = "8196be9d7958059cb56c6c75c80fdf6cee8a8885bc149ea791d7db1c7ef93035"