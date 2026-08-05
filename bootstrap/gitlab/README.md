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

5. Initialise Terraform and install required providers.

```bash
# Initialise Terraform and install providers.
terraform -chdir="./terraform" init -upgrade
```

6. Deploy Terraform to provision resources, referencing the top-level global variables directory.

```bash
# Deploy Terraform code to provision resources, referencing the top-level global variables file.
terraform -chdir="./terraform" apply -var-file="../../../variables/global-proxmox.tfvars"
```

7. Copy generated SSH keys to local user profile for password-less SSH access to the VM.

```bash
cp -f ssh_keys/gitlab-ssh ~/.ssh/gitlab-ssh
cp -f ssh_keys/gitlab-ssh.pub ~/.ssh/gitlab-ssh.pub
```

8. **(Optional):** Display default user password.

```bash
terraform -chdir="./terraform" output -raw gitlab_default_user_password
```

9. Update OPNsense firewall rules to allow `Trusted-WAN` device to connect via SSH and HTTP to the new GitLab VM.

| Name                               | Interface | Action | Direction |
| ---------------------------------- | --------- | ------ | --------- |
| Allow_WAN-Trusted_SVR20-GitLab_MGT | WAN       | Pass   | In        |

| Version | Protocol | Source      | Source Port | Destination      | Destination Port |
| ------- | -------- | ----------- | ----------- | ---------------- | ---------------- |
| IPv4    | TCP/UDP  | WAN_Trusted | Any         | SVR_Hosts_GitLab | Ports_Mgmt       |

10. Execute Ansible code to deploy and configure the GitLab service.

