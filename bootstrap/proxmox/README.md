# 🥾 Bootstrap: Proxmox (Ansible + Terraform)

This process provisions the necessary resources and components to manage Proxmox using automation pipelines.
The goal is to produce a bootstrapping process that is solid and repeatable.

Using separate dedicated service accounts for both configuration and infrastructure provides "separation of duties", and a clear boundary between the role of each deployment stage (deploy VM infra vs configure VM system).

**Ansible**

A local service account for Ansible is required on each Proxmox node to perform host-level configuration operations.
This includes installing and updating packages, and making operating system changes.
Using a dedicated service account avoids using the heavy privileged `root` account, which is only used for the initial bootstrapping.

**Terraform**

Unlike the Ansible account, the Terraform service account is provisioned within the Proxmox instance only.
This means that it _does not_ have the ability to login to the operating system layer, as this is not required for the tasks it will perform.
The role of the Terraform service account is to deploy resources within the Proxmox instance.

---

## 🌳 Resources

- **SSH Key-Pair:** Provides passwordless SSH login access to resources managed by Ansible.
- **Ansible Service Account (Local):** Used to manage and apply configuration to the Proxmox nodes and workloads at host level.
- **Terraform Service Account (API):** Authenticates to the Proxmox API to deploy and manage infrastructure (VMs, containers etc).
- **Proxmox User Group:** Enables service accounts to inherit assigned permissions and role within Proxmox.

---

## 💡 Requirements

- [x] Ansible installed locally on the system performing bootstrap process (workstation).
- [x] Proxmox cluster installed with initial configuration completed.
- [x] SSH Connectivity to all Proxmox nodes (`TCP/22`).

---

## 📙 Preparation Steps

- [x] Remove stale SSH host keys if rebuild has occurred to avoid SSH connection issues.
  - If the same IPs were used before the rebuild, the file `~/.ssh/known_hosts` will have stale host keys and SSH will refuse to connect. 
  - Execute: `ssh-keygen -R <node_ip>`
- [x] Confirm SSH access to the `root` account on all Proxmox nodes.
- [x] Update the Ansible inventory file (`inventory.ini`) if hostnames or IP addressing have changed.

---

## ▶️ Usage Process

**1. Execute Proxmox bootstrapping script:**

- Generates a dedicated `ed25519` SSH key-pair for Ansible service account in working directory.
- **For each Proxmox node:**
  - Create local service account for Ansible.
  - Inject SSH public key into `~/.ssh/authorized_keys` for the Ansible service account.
    - This enables Ansible to apply configuration at host level.
- Creates Proxmox service account group and assigns required permissions.
- Creates Proxmox service account users with API token access.

```bash
./bootstrap-proxmox.sh
```

**2. Execute Proxmox template bootstrapping script:**

- Downloads Ubuntu Server cloud-init image and configures VM template.
- VM template (Ubuntu) is required for Git server bootstrapping.

```bash
./bootstrap-ubuntu-template.sh
```

**3. Move SSH keys to `files/ssh-keys` directory:**

- Enables central storage location of commonly used keys.

```bash
mv svc-ansible.ssh* ../../files/ssh_keys
```

---

## 🅾️ OPTIONAL: Local Service Account Removal

To delete the `svc-ansible` user and remove configuration, login to each node and execute the following:

```bash
# Ensure user processes are stopped if running.
loginctl terminate-user svc-ansible
# -r: Instructs the system to remove the user home directory and mail spool.
userdel -r svc-ansible
# Remove user entry from sudoers config.
rm -f /etc/sudoers.d/svc-ansible
```
