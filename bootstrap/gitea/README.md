# Bootstrap: Gitea

Bootstrap a Gitea instance within a Proxmox VM to provide a local code repository, repo mirroring and local runner for execution of pipelines.

## 🧭 Strategy

- Terraform to provision the SSH key-pair and a new VM in Proxmox from existing template.
- Azure blob storage for remote Terraform backend.
- Ansible to install and configure Gitea on new VM.
- Configure repo mirroring for GitHub repository (source of truth) to the local Gitea instance.

---

## ❓ Requirements

- [x] Terraform installed locally.
- [x] Ansible installed locally.
- [x] **Optional**: Azure CLI installed and authenticated (when using Azure backend).

---

## 🌳 Resources

| Name            | Purpose                                             |
| --------------- | --------------------------------------------------- |
| Proxmox VM      | VM to run the Gitea instance                        |
| SSH Key Pair    | Used for password-less SSH authentication to the VM |
| Gitea Instance  | Gitea instance running on the Proxmox VM            |

---

## ▶️ Usage

**Preparation**

1. Copy the example files from `./terraform/examples` to the `./terraform` directory.
2. Rename the example files to remove the text`-example` from the file names.
3. Update the `backend.tf` file to reference real Azure resources for remote state storage.
4. Update the `terraform.tfvars` file with desired variable values for the environment.

**Deployment**

5. Execute the bootstrapping script to deploy the Proxmox VM and execute Ansible playbook.

```bash
./bootstrap-gitvm.sh
```

6. Wait for Terraform to deploy the VM, and Ansible to configure the VM.
7. Update OPNsense firewall rules to allow `Trusted-WAN` device to connect via SSH and HTTP to the new VM.

| Name                             | Interface | Action | Direction |
| -------------------------------- | --------- | ------ | --------- |
| Allow_WAN-Trusted_SVR20-Git_Mgmt | WAN       | Pass   | In        |
| Allow_WAN-Trusted_SVR20-Git_Web  | WAN       | Pass   | In        |

| Version | Protocol | Source      | Source Port | Destination   | Destination Port |
| ------- | -------- | ----------- | ----------- | ------------- | ---------------- |
| IPv4    | TCP/UDP  | WAN_Trusted | Any         | SVR_Hosts_Git | Ports_Mgmt       |
| IPv4    | TCP/UDP  | WAN_Trusted | Any         | SVR_Hosts_Git | Ports_Web        |

8. **OPTIONAL:** Execute the bootstrapping script with `--destroy` flag to completely remove the resources.

```bash
./bootstrap-gitvm.sh --destroy
```
