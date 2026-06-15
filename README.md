# Home Lab

Welcome to my personal home lab! :wave:  

This project provides an environment for self-hosting and experimenting with different technologies.
A base for hands-on learning, developing knowledge and improving my skills.

As a big fan of small tech (micro-pcs, Raspberry Pi etc), a primary requirement is maintaining a small footprint for my on-prem environment.
I aim to re-use as much existing hardware as possible, recycling second hand gear and giving it a new life in my lab.

_For more in-depth details on how to configure Proxmox and other platforms, check out my website where I share guides and other articles._

🌏 [Personal Website](https://tshand.com/)

![Current home lab hardware.](./docs/images/homelab_current.jpg)

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

The design for this project places the home lab network behind the existing home network. This design is relatively simple and allows room for expansion.

- The home lab network exists **behind** the lab firewall, connected to the existing home network.
- The firewall WAN address is provided by the ISP provided WiFi router using a DHCP reservation.
- A static route entry is added to the ISP router to direct connections from the home network into the lab network via the firewall WAN IP.
- Virtual server workloads are isolated on dedicated VLANs for improved security and network traffic control.

![Home Lab Design](./docs/images/homelab_design.png)

---

## 🖥️ Hardware & Components

### 🏭 Hypervisors

Refurbished mini-PCs running [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) as the virtualisation layer. 
Chosen due to being free (zero-cost) and open source, with extensive vendor and user documentation available.

- **Lenovo Thinkcentre P330 Tiny (x2)**
  - Chosen for its minimal size and dual M.2 slots.
  - Can accept an additional low-profile NIC (requires PCIe riser), providing extra LAN port capabilities.
  - M.2 WiFi card slot inhabited by 2.5Gb Ethernet card providing dedicated workload interfaces.
  - **Compute:**
    - Intel i5-9500 (6 Core, 6 Thread, 3.00 GHz)
    - 16GB (DDR4, 1x 16GB SODIMM)
  - **Storage:**
    - Boot/OS: 256GB NVMe
    - Data: 1TB NVMe
- **Lenovo Thinkcentre M700 (x1)**
  - Third Proxmox node, replacing Raspberry Pi QDevice. 
  - Can accept an additional low-profile NIC (via M.2 Ethernet adapter).
  - **Compute:**
    - Intel i5-6400T (4 Core, 4 Thread, 2.20 GHz)
    - 8GB (DDR4, 1x 8GB SODIMM)
  - **Storage:**
    - Boot/OS: 256GB SATA SSD
    - Data: N/A
- **Raspberry Pi 1B+ (x1) _(Decommissioned)_**
  - Was running as a QDevice, maintaining Proxmox cluster quorum (required for two-node clusters).
  - Replaced and awaiting repurpose as environmental monitoring agent.

### 🧱 Firewall

A twin of my third Proxmox node. A second Lenovo M700 running [OPNsense](https://opnsense.org/get-started/).
Dedicated as a physical firewall appliance, using the ISP provided router as upstream WAN gateway.

- **Lenovo Thinkcentre M700**
  - **Compute:**
    - Intel i5-6400T (4 Core, 4 Thread, 2.20 GHz)
    - 8GB (DDR4, 1x 8GB SODIMM)
  - **Storage:**
    - Boot/OS: 256GB SATA SSD
  - **Networking:**
    - WAN: On-board 1Gb NIC, connected to home ISP router.
    - LAN: M.2 Ethernet Adapter 2.5Gb (Intel i226-V Gigabit 2.5G)

> Check out [this blog post](https://tshand.com/posts/homelab-08-update/#new-hardware--components) on how I replaced the original M.2 WiFi adapter with 2.5Gb Ethernet.

### 🌐 Networking

- **Switch: TP Link TL-SG108PE**
  - Managed 8 port switch supporting VLANs.
  - Capable of PoE (Power over Ethernet), although this is not being used, and has been disabled.

```text
Proxmox Node 1 (prd)
    eth0 → untagged → INF10 (10.0.10.1/24) → vmbr0
    eth1 → trunk → managed switch
               ├── VLAN 20 (MGT20) → vmbr1 (VLAN-aware)
               └── VLAN 30 (SVR30) → vmbr1 (VLAN-aware)

Proxmox Node 2 (prd)
    eth0 → untagged → INF10 (10.0.10.2/24) → vmbr0
    eth1 → trunk → managed switch
               ├── VLAN 20 (MGT20) → vmbr1 (VLAN-aware)
               └── VLAN 30 (SVR30) → vmbr1 (VLAN-aware)

Proxmox Node 3 (dev)
    eth0 → untagged → INF10 (10.0.10.3/24) → vmbr0
    No vmbr1, dev node, no ZFS pool, no workload bridge
```

---

## 🧩 Workloads

- Self-hosted GitLab instance for repo mirroring and executing pipelines locally.
- Virtualized [pfSense](https://www.pfsense.org/download/) VM (for internal lab use).
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

Please refer to the [docs](docs/) directory for documentation and guides on how this environment is configured.

---
