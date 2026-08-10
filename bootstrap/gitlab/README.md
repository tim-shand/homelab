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
cp -f ssh_keys/gitlab-ssh ~/.ssh/gitlab-ssh && cp -f ssh_keys/gitlab-ssh.pub ~/.ssh/gitlab-ssh.pub
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

```bash
ansible-playbook -i inventory.ini -u homelabadmin gitlab_server.yaml -vv
```

> [!NOTE]
> If the bootstrapping process is re-run, it is possible that host key verification may fail.
> An SSH `Host key verification failed` error occurs when the public identity key presented by the remote server does not match the cryptographic key fingerprint the local computer previously saved for that specific address.
> For example, this can happen when a VM is deployed, connected to via SSH, then the VM is destroyed and redeployed.
> There will be mismatch between what the local host expects the host key to be based on an entry in the `~/.ssh/known_hosts` file.

11. **(Optional):** Purge the previously stored host key from known hosts and add the new host key.

```bash
ssh-keygen -R 10.0.20.10
ssh-keyscan -H 10.0.20.10 >> ~/.ssh/known_hosts
```
