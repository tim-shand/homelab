# Bootstrap: GitLab CE

Bootstrap a GitLab instance within a Proxmox VM to provide a local code repository, GitHub repo mirroring and local execution of pipelines.

## Strategy

- Terraform to provision the VM in Proxmox.
- Ansible to configure the GitLab instance once VM is deployed.
- Mirror GitHub repository (source of truth) to the local GitLab instance.

## Requirements

## Process

- Manually execute Terraform code using Azure backend to deploy GitLab VM from Ubuntu Proxmox template.
- Update OPNsense firewall rules are updated to allow `Trusted-WAN` device to connect via SSH to the new GitLab VM.
- Execute Ansible code to deploy and configure the GitLab service.

## Usage

```bash
# Set path to global variables directory.
TF_VARS_DIR="../../.."
```

```bash
terraform init -upgrade
terraform validate
```

```bash
terraform plan -var-file="$TF_VARS_DIR/global-proxmox.tfvars"
```

