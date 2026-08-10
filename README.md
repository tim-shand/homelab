# 🏠 Personal Home Lab

Welcome! This repo documents my personal home lab.
A self-hosted private cloud environment used for hands-on learning, infrastructure experimentation, and developing my skill set.

As a big fan of small tech, a primary requirement is to maintain a small physical footprint.
I aim to utilise as much existing hardware as possible by recycling second hand gear to give it a new life in my lab.

> [!TIP]
> Guides and articles about how this lab was built can be found on my [website](https://tshand.com/tags/homelab/).

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
| IaC             | Terraform, Ansible                       |
| Scripting       | Bash, PowerShell                         |
| Storage         | ZFS pools, NFS, Azure Blob (state files) |

---

## 🏛️ Design & Architecture

The lab sits behind a dedicated OPNsense firewall, isolated from the home network and segmented into VLANs for management, workloads, and DMZ traffic. 
A three-node Proxmox cluster runs virtualised workloads, with Proxmox Software-Defined Networking (SDN) used to manage VLAN assignment at the hypervisor level.

> [!NOTE]
> Full topology, VLAN tables, and firewall design:
> [Architecture](docs/architecture.md)

![Home Lab Design](docs/images/homelab_architecture.png)

---

## 🧩 Workloads

| Workload             | Purpose                                                 |
| -------------------- | ------------------------------------------------------- |
| PFsense/OPNsense VMs | Internal firewall testing and lab network experiments.  |
| Management/Jump Host | Access point into lab management interfaces.            |
| GitLab CE            | Version control, repo mirroring, on-prem runners.        |
| Misc utility VMs     | Testing, sand boxing, and evaluating new tech.          |

---

## 🛠️ Tools & Utilities

- **[Terraform](https://www.terraform.io/):** Provider agnostic IaC tool for deploying and managing resources declaratively.
- **Azure Blob Storage:** Used to store remote state files for Terraform deployments.
- **Bash/PowerShell:** Bootstrapping scripts and miscellaneous automation utilities.

---

## 👢 Bootstrapping

Using bootstrap scripts allows the home lab to be easily re-deployed in the event of total failure.
Utilising a combination of Bash, Terraform and Ansible, essential workloads can be redeployed and configured.

See the [bootstrap](./bootstrap/) directory for guidance on the correct sequence of steps.

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
