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
| Firewall/Router | OPNsense + 802.1Q VLANs                  |
| Networking      | TP-Link managed switch, Proxmox SDN      |
| Automation      | Terraform, Ansible, Gitea Actions        |
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

## 🖥️ Hardware & Components

### Hypervisors

The Proxmox cluster resides on three refurbished mini-PCs running [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) as the virtualisation layer. Proxmox was chosen for the hypervisor due to being free (zero-cost) and open source, with extensive vendor and user documentation available.

**Lenovo Thinkcentre P330 Tiny (x2)**

- Small physical footprint _(known as "1-litre PCs")_.
- Accessible price point, these average around NZD$350 in local used markets.
- Dual M.2 NVMe slots for easy storage expansion.
- PCIe expansion slot for an additional network adapter, graphics card, or increasing storage capabilities.
  - **Note:** Requires a specific PCIe riser, part number #01AJ940.
- M.2 WiFi card slot can be [replaced with an Ethernet adapter](https://tshand.com/posts/homelab-08-update/), providing additional networking capabilities.

**Lenovo Thinkcentre M700 Tiny (x1)**

- Same physical size of the P330 Tiny, fits in well with existing hardware.
- Cheaper price point of around NZD$180.
- Limited to older 6th-Gen Intel Core processors.
- Single M.2 NVMe slot available for storage expansion.
- M.2 WiFi card slot for expanding network capabilities with additional network card.
- Third node to replace old Raspberry Pi [QDevice](https://tshand.com/posts/homelab-04-proxmox-cluster-qdevice/).

**Compute:**

| Name           | Make/Model                   | CPU                              | Memory              |
| -------------- | ---------------------------- | -------------------------------- | ------------------- |
| inf-pve-01-prd | Lenovo ThinkCentre P330 Tiny | Intel i5-9500  (6C/6T, 3.0 GHz)  | 16 GB DDR4 (2x 8GB) |
| inf-pve-02-prd | Lenovo ThinkCentre P330 Tiny | Intel i5-9500  (6C/6T, 3.0 GHz)  | 16 GB DDR4 (2x 8GB) |
| inf-pve-03-dev | Lenovo ThinkCentre M700 Tiny | Intel i5-6400T (4C/4T, 2.2 GHz)  | 8 GB DDR4 (1x 8GB)  |

**Storage:**

| Name           | Drive 1 (SATA) | Drive 2 (NVMe) | Drive 3 (NVMe)   |
| -------------- | -------------- | -------------- | ---------------- |
| inf-pve-01-prd | Empty          | 256 GB (OS)    | 1 TB (Data: ZFS) |
| inf-pve-02-prd | Empty          | 256 GB (OS)    | 1 TB (Data: ZFS) |
| inf-pve-03-dev | 256 GB (OS)    | Empty          | N/A              |

**Networking:**

| Name           | NIC 1 (Onboard)        | NIC 2 (M.2 Slot)      |
| -------------- | ---------------------- | --------------------- |
| inf-pve-01-prd | Intel I219-LM (rev 10) | Intel I226-V (rev 04) |
| inf-pve-02-prd | Intel I219-LM (rev 10) | Intel I226-V (rev 04) |
| inf-pve-03-dev | Intel I219-V (rev 31)  | Empty                 |

### Networking

**Firewall (OPNsense)**

- A Lenovo M700 is configured and running [OPNsense](https://opnsense.org/get-started/).  
- Dedicated as a physical firewall appliance, also provides routing, VLAN, DNS and DHCP functionality.
- **Compute:** Intel i5-6400T (4C/4T, 2.2 GHz), 8 GB DDR4 (1x 8GB)
- **Storage:** 256 GB SSD
- **Networking:**
  - NIC 1 (Onboard): Intel I219-V (rev 31)
  - NIC 2 (M.2 Slot): Intel I226-V (rev 04)

**Core Switch (TP Link TL-SG108PE)**

- Basic 8 port "smart" managed gigabit switch, supporting VLANs (802.1Q and port based).
- Capable of PoE (Power over Ethernet), although this is not being used currently, and has been disabled.

### Additional Devices

**Raspberry Pi 1B+ (Decommissioned)**

- Very old Raspberry Pi model, running Debian 13 Trixie (barely).
  - Requires using the 32-bit Debian architecture and sticking a CLI-only (headless) environment.
- Was running as a QDevice, maintaining Proxmox cluster quorum (required for two-node clusters).
- Replaced by the Lenovo M700 and awaiting a new purpose as environment monitoring agent.

---

## 🧩 Workloads & Apps

| Workload                 | Purpose                                                 |
| ------------------------ | ------------------------------------------------------- |
| Git Server (Gitea)       | Version control, repo mirroring, on-prem CI/CD runners. |
| Management/Jump Host     | Server providing access into lab environment.           |
| Docker Hosts             | Provide containerised application and services.         |
| Monitoring/Observability | Zabbix for infrastructure and server monitoring.        |

---

## 🥾 Bootstrapping Process

Preparing bootstrap scripts allows the environment to be easily re-deployed in the event of total failure.
Utilising a combination of Bash, Terraform and Ansible, essential workloads and infrastructure can be redeployed and configured easily.

> [!TIP]
> See the [Bootstrap](./bootstrap/) directory for more details on sequence of tasks.

**Proxmox**

- Dedicated Proxmox service accounts for Ansible and Terraform with tokens for authentication into via API.
- Local service account for Ansible provisioned on each node on the cluster for host-level configuration.
- SSH keys for passwordless authentication during workflow execution.

**Git Server**

- Proxmox VM deployed from VM template.
- Install and configure Gitea post-deployment using Ansible role.
- Configure local runner to enable workflow execution, required to deploy lab infrastructure.

---

## 🛠️ Tools & Utilities

- **[Terraform](https://www.terraform.io/):** Provider agnostic IaC tool for deploying and managing resources declaratively.
- **[Ansible](https://docs.ansible.com):** Configuration as Code tool for apply post-deployment settings and configuration.
- **Azure Blob Storage:** Used to store remote state files for Terraform deployments.
- **Bash/PowerShell:** Bootstrapping scripts and miscellaneous automation utilities.

---

## 🔬 Issues & Solutions

Issues are recorded and held within the [Issues](./docs/issues/) directory as individual files. 
When the issue is accepted, mitigated or resolved, the file is moved to the resolved directory.

_See the [Issues Register](/docs/issues/README.md) for details on active and resolved issues._

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
