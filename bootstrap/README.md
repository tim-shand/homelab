# Bootstrap Sequence

This process describes the steps required to re-build my home lab from scratch.
Everything in Layer 0 and Layer 1 is performed once. All subsequent and future infrastructure is managed via GitLab pipelines.

## Prerequisites (Layer 0: Manual, Run Once)

- [ ] Physical hardware installed and connected.
- [ ] Managed switch configured for VLANs using tagged and untagged with PVID.
- [ ] OPNsense installed or configuration imported from backup.
- [ ] VLANs configured (MGT10, SVR20).
- [ ] Firewall rules configured, enable trusted WAN and inter-VLAN connectivity (if required).
- [ ] DNS entries created in OPNsense Unbound (or imported via backup).
- [ ] Proxmox cluster installed and configured (all three nodes).
- [ ] Bootstrap script run against Proxmox cluster.
- [ ] Proxmox API token saved to Azure Key Vault (or Password Manager).
- [ ] Azure Resource Group, Storage Account and Key Vault created for Terraform remote state.

## PKI Bootstrap (Layer 1: Manual, Run Once)

- [ ] Root CA VM provisioned using Terraform and Ansible.
  - `terraform -chdir="./bootstrap/pki-rootca/terraform" apply`
  - `ansible-playbook ./bootstrap/pki-rootca/ansible/setup.yml`
- [ ] Root CA generated on VM.
  - `ansible-playbook ./bootstrap/pki-rootca/ansible/generate-ca.yml`
- [ ] Intermediate CA signed and exported to OPNsense.
- [ ] Root CA VM shut down (keep offline from now on).
- [ ] Service certificates issued for all current services.
- [ ] Certificates deployed to Proxmox nodes
  - `scripts/deploy-proxmox-cert.sh`

## GitLab Bootstrap (Layer 1: Manual, Run Once)

- [ ] Deploy GitLab container using Terraform
  - `terraform -chdir="./bootstrap/gitlab/terraform" apply -var-file="terraform.tfvars"`
- [ ] Execute configuration phase using Ansible playbook.
  - `ansible-playbook ./bootstrap/gitlab/ansible/gitlab.yml`
- [ ] GitLab mirroring configured to pull from GitHub to on-prem.
- [ ] GitLab CI variables setup.
- [ ] Temporary runner registered.

## Steady State (Layer 2: Pipeline Driven)

All further changes are made via the GitLab pipeline.
