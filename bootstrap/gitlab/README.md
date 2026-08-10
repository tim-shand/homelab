# Bootstrap: GitLab CE

Bootstrap a GitLab instance within a Proxmox VM to provide a local code repository, GitHub repo mirroring and local execution of pipelines.

## 🧭 Strategy

- Terraform to provision the SSH key-pair and a new VM in Proxmox from template.
- Ansible to configure the GitLab instance once VM is deployed.
- Mirroring for GitHub repository (source of truth) to the local GitLab instance.

## ❓ Requirements

- [x] Terraform installed locally.
- [x] Ansible installed locally.
- **Optional**: Azure CLI installed and authenticated (if using Azure backend).

## 🌳 Resources

| Name            | Purpose                                             |
| --------------- | --------------------------------------------------- |
| Proxmox VM      | VM to run the GitLab instance                       |
| SSH Key Pair    | Used for password-less SSH authentication to the VM |
| GitLab Instance | GitLab CE instance running on the Proxmox VM        |

## ▶️ Usage

1. Copy the example files from `./terraform/examples` to the `./terraform` directory.
2. Rename the example files to remove the text`-example` from the file names.
3. Update the `backend.tf` file to reference real Azure resources for remote state storage.
4. Update the `terraform.tfvars` file with desired variable values for the environment.

5. Execute the bootstrapping script.

```bash
./bootstrap-gitlab.sh
```

6. Wait for Terraform to deploy the VM, Ansible to configure the VM and install GitLab CE.
7. Update OPNsense firewall rules to allow `Trusted-WAN` device to connect via SSH and HTTP to the new GitLab VM.

| Name                               | Interface | Action | Direction |
| ---------------------------------- | --------- | ------ | --------- |
| Allow_WAN-Trusted_SVR20-GitLab_MGT | WAN       | Pass   | In        |

| Version | Protocol | Source      | Source Port | Destination      | Destination Port |
| ------- | -------- | ----------- | ----------- | ---------------- | ---------------- |
| IPv4    | TCP/UDP  | WAN_Trusted | Any         | SVR_Hosts_GitLab | Ports_Mgmt       |

8. **OPTIONAL:** Execute the bootstrapping script with flag `-d` to completely remove the resources and GitLab instance.

```bash
./bootstrap-gitlab.sh --destroy
```
