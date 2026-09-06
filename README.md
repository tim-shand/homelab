# 🏠 Private Cloud Micro Datacenter (Personal Home Lab)

Welcome! This project contains the documentation and codebase for my personal home lab.

A self-hosted private cloud environment used for hands-on learning, infrastructure experimentation, and developing my skill set.

As a big fan of small tech, a primary requirement is to maintain a small physical footprint.  
I aim to utilise as much existing hardware as possible by recycling second hand gear to give it a new life in my lab.

> [!TIP]
> Visit my [website](https://tshand.com/tags/homelab/) for further in-depth articles on how this project is built.

![Current home lab hardware.](docs/images/homelab_current_01.jpg)

---

## 🎯 Goals & Objectives

- Use existing or refurbished hardware, reducing cost and maximising technology lifespan.
- Enforce network segmentation between home and lab zones using a dedicated firewall and VLAN architecture.
- Implement high availability, redundancy, and best practices where applicable.
- Manage infrastructure declaratively using Terraform and version control.
- Automate deployments via CI/CD pipelines running on self-hosted GitLab.
- Maintain a small physical footprint for both practicality and aesthetics.

---

## 💡 Tech Stack

| Layer           | Technology                               |
| --------------- | ---------------------------------------- |
| Hypervisor      | Proxmox VE (3-node cluster)              |
| Firewall/Router | OPNsense                                 |
| Networking      | TP-Link managed switch, 802.1Q VLANs     |
| IaC/Config      | Terraform, Ansible                       |
| Scripting       | Bash, PowerShell                         |
| Storage         | ZFS pools, NFS, Azure Blob (state files) |

---

## 🏛️ Design & Architecture

The lab sits behind a dedicated OPNsense firewall, isolated from the home network and segmented into VLANs for management, workloads, and DMZ traffic. 
A three-node Proxmox cluster runs virtualised workloads, with Proxmox Software-Defined Networking (SDN) used to manage VLAN assignment at the hypervisor level.

> [!NOTE]
> Full topology, VLAN tables, and firewall design can be found [here](docs/architecture.md).

![Home Lab Design](docs/images/homelab_architecture.png)

---

## 🧩 Workloads

| Workload                 | Purpose                                                 |
| ------------------------ | ------------------------------------------------------- |
| Git Server (Gitea)       | Version control, repo mirroring, on-prem CI/CD runners. |
| Management/Jump Host     | Server providing access into lab environment.           |
| Docker Hosts             | Provide containerised application and services.         |
| Monitoring/Observability | Zabbix for infrastructure and server monitoring.        |

---

## 🛠️ Tools & Utilities

- **[Terraform](https://www.terraform.io/):** Provider agnostic IaC tool for deploying and managing resources declaratively.
- **[Ansible](https://docs.ansible.com):** Configuration as Code tool for apply post-deployment settings and configuration.
- **Azure Blob Storage:** Used to store remote state files for Terraform deployments.
- **Bash/PowerShell:** Bootstrapping scripts and miscellaneous automation utilities.

---

## 🥾 Bootstrapping

Preparing bootstrap scripts allows the environment to be easily re-deployed in the event of total failure.
Utilising a combination of Bash, Terraform and Ansible, essential workloads and infrastructure can be redeployed and configured easily.

> [!TIP]
> See the [Bootstrap](./bootstrap/) directory for guidance on the correct sequence of bootstrap steps.

**[Proxmox](./bootstrap/proxmox)**

- Dedicated Proxmox service accounts for Ansible and Terraform with tokens for authentication into via API.
- Local service account for Ansible provisioned on each node on the cluster for host-level configuration.
- SSH keys generated for passwordless authentication during pipeline execution.

**[Git Server](./bootstrap/gitea)**

- Bash script calls Terraform to provision Proxmox VM from template.
- Deploys and configures Gitea post-deployment using Ansible role.
- Installs local runner to enable workflow execution required to deploy lab infrastructure.

---

## 🔬 Issues & Solutions

Issues are recorded and held within the [Issues](./docs/issues/) directory as individual files. 
When the issue is accepted, mitigated or resolved, the file is moved to the resolved directory.

See the [Issues Register](/docs/issues/README.md) for details on active and resolved issues.

---

## 📚 Documentation

Refer to the [docs](docs/) directory for more information covering operations, configuration and design.

| Name                                      | Purpose                                       |
| ----------------------------------------- | --------------------------------------------- |
| [Architecture](/docs/architecture.md)     | Topology, VLANs, SDN design.                  |
| [Hardware](/docs/hardware.md)             | Device specs, upgrades, expansion.            |
| [Configuration](/docs/configuration.md)   | Proxmox, OPNsense, switch config, automation. |
| [Issues Register](/docs/issues/README.md) | Register for issues and solutions.            |

---
