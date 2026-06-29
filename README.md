# Personal Home Lab (Private Cloud)

Welcome to my personal home lab! :wave:  

This project provides an environment for self-hosting and experimenting with different technologies.
A base for hands-on learning, developing knowledge and improving my skills.

As a big fan of small tech (micro-pcs, Raspberry Pi etc), a primary requirement is maintaining a small footprint for my on-prem environment.
I aim to re-use as much existing hardware as possible, recycling second hand gear and giving it a new life in my lab.

> [!TIP]
> Check out my [website](https://tshand.com/tags/homelab/) where I share guides on how this home lab was configured.

![Current home lab hardware.](docs/images/homelab_current_01.jpg)

---

## 🎯 Goals & Objectives

- Use existing or refurbished hardware, reducing cost and maximizing technology lifespan.
- Isolation of networks, providing a separation of lab and existing home networks.
- Implement high availability, redundancy and best practices where applicable.
- Utilise both infrastructure and configuration as code where possible.
- Automate deployments, using Git for version control and workflows/pipelines for CI/CD.
- Maintain a small physical footprint, for both atheistic and practicality purposes.

---

## 🏛️ Design & Architecture

The design for this project places the home lab network behind the existing home network. 
This design is relatively simple and allows room for future expansion.

- The home lab network exists **behind** the lab firewall, connected to the existing home network.
- The firewall WAN address is provided by the ISP provided WiFi router using a DHCP reservation.
- A static route entry is added to the ISP router to direct connections from the home network into the lab network via the firewall WAN IP.
- Virtual server workloads are isolated on dedicated VLANs for improved security and network traffic control.

> [!NOTE]
> Further details on architecture and design can be found in the [Architecture](/docs/architecture.md) documentation.

![Home Lab Design](docs/images/homelab_architecture.png)

## 🏛️ Design & Architecture

The lab network sits behind a dedicated OPNsense firewall, isolated from
the home network and segmented internally by VLAN.

> [!NOTE]
> Full topology, VLAN tables, and firewall rule design live in
> [Architecture](docs/architecture.md).

![Home Lab Design](docs/images/homelab_architecture.png)

---

## 🖥️ Hardware & Components

### 🏭 Hypervisors (Proxmox)

The Proxmox cluster resides on three refurbished mini-PCs running [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) as the virtualisation layer. Proxmox was chosen for the hypervisor due to being free (zero-cost) and open source, with extensive vendor and user documentation available.

**Lenovo Thinkcentre P330 Tiny**

- Small physical footprint _(known as "1-litre PCs")_.
- Accessible price point, these average around NZD$350 in local used markets.
- Dual M.2 NVMe slots for easy storage expansion.
- PCIe expansion slot for an additional network adapter, graphics card, or increasing storage capabilities.
  - **Note:** Requires a specific PCIe riser, part number #01AJ940.
- M.2 WiFi card slot can be [replaced with an Ethernet adapter](https://tshand.com/posts/homelab-08-update/), providing additional networking capabilities.

**Lenovo Thinkcentre M700 Tiny**

- Same physical size of the P330 Tiny, fits in well with existing hardware.
- Cheaper price point of around NZD$180.
- Limited to older 6th-Gen Intel Core processors.
- Single M.2 NVMe slot available for storage expansion.
- M.2 WiFi card slot for expanding network capabilities with additional network card.
- Replaced old Raspberry Pi [QDevice](https://tshand.com/posts/homelab-04-proxmox-cluster-qdevice/), adding a proper third node to the cluster.

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


### 🧱 Firewall (OPNsense)

A twin of the third hypervisor node, a second Lenovo M700 is configured running [OPNsense](https://opnsense.org/get-started/).
Dedicated as a physical firewall appliance, provides firewall, routing, VLAN, DNS and DHCP functionality.

**Compute:**

| Name           | Make/Model                   | CPU                              | Memory             |
| -------------- | ---------------------------- | -------------------------------- | ------------------ |
| inf-net-fwl-01 | Lenovo ThinkCentre M700 Tiny | Intel i5-6400T (4C/4T, 2.2 GHz)  | 8 GB DDR4 (1x 8GB) |

**Storage:**

| Name           | Drive 1 (SATA) | Drive 2 (NVMe) | Drive 3 (NVMe)   |
| -------------- | -------------- | -------------- | ---------------- |
| inf-pve-01-prd | 256 GB (OS)    | Empty          | N/A              |

**Networking:**

| Name           | NIC 1 (Onboard)        | NIC 2 (M.2 Slot)      |
| -------------- | ---------------------- | --------------------- |
| inf-pve-03-dev | Intel I219-V (rev 31)  | Intel I226-V (rev 04) |

> [!TIP]
> Check out [this blog post](https://tshand.com/posts/homelab-08-update/#new-hardware--components) for details on replacing the original M.2 WiFi adapter with 2.5Gb Ethernet adapter.

### 🌐 Networking

**Switch (TP Link TL-SG108PE)**

- Basic 8 port "smart" managed switch, supporting VLANs (802.1Q and port based).
- Capable of PoE (Power over Ethernet), although this is not being used currently, and has been disabled.

---

## 🧩 Workloads

- Self-hosted GitLab instance for repo mirroring and executing automation pipelines locally.
- Virtualized [pfSense](https://www.pfsense.org/download/) VM (for internal lab/testing usage).
- Management and jump host servers, test and misc utility VMs.

---

## 🛠️ Tools & Utilities

- **[Terraform](https://www.terraform.io/)**
  - Provider agnostic IaC tool, free to use, plenty of discussion, guides and support available.
  - Deploy and manage resources using dedicated providers.
  - **Alternatives:** Pulumi, OpenTofu.
- **Bash/Powershell**
  - Bootstrapping and misc utility scripts.

---

## 📚 Documentation

Please refer to the [docs](docs/) directory for information covering operations, configuration and design.

| Name                                    | Purpose                                       |
| --------------------------------------- | --------------------------------------------- |
| [Architecture](/docs/architecture.md)   | Topology, VLANs, SDN design.                  |
| [Hardware](/docs/hardware.md)           | Device specs, upgrades, expansion.            |
| [Configuration](/docs/configuration.md) | Proxmox, OPNsense, switch config, automation. |

---
