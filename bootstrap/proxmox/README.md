# Bootstrap: Proxmox (Service Account for IaC)

The Proxmox bootstrap process is performed using a single bash script.

It is intended to be a **run-once solution**, creating a dedicated service account with API token.
This account can then be used with automation pipelines, preparing for future IaC deployments.

- Portable, simple to read, easy to execute.
- Removes application requirements (no need to install Terraform or Ansible).
- No state file to manage or store post deployment.
- Uses Proxmox native terminal command `pveum` to create resources.

---

## Resources

- **Role:**
  - Custom role with necessary actions assigned for IaC accounts, using least privilege.
- **Group:**
  - Dedicated group for service accounts with custom role assignment.
- **Service Account:**
  - Added as a member of the IaC service account group, inheriting the assigned permissions from group. 
- **API Token:**
  - Generated for the service account to use when authenticating with Proxmox API.

---

## Requirements

[x] Root account credentials to the Proxmox environment.
[x] SSH access to a target Proxmox node, either singular or in a cluster.

---

## Usage

1. Execute from a device with SSH connectivity to a Proxmox node or nodes within a cluster.

```shell
ssh root@proxmox-node 'bash -s' < scripts/bootstrap-proxmox.sh
```

2. Save the token secret from output, storing securely in a password manager or CI/CD pipeline secrets.

---
