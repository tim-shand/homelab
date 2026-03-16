# Home Lab (Proxmox) - Part 1: Getting Started

This article describes the initial design and installation process involved to configure the home lab environemnt.

> [!NOTE]
> Some steps in this guide may not be applicable or suit your requirements, and can therefore be skipped if needed. I aim to keep the information as accurate as possible, however some details and decisions may change over the course/lifespan of the project.

---

## 📚 Documentation

Please refer to the [docs](docs/) directory for documentation and guides on how this environment is configured.

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

---

## 🖥️ Hardware & Components

### 🏭 Hypervisors

Refurbished mini-PCs running [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) as the virtualisation layer. Chosen due to being free (zero-cost) and open source, with extensive vendor and user documentation available.

- **Lenovo Thinkcentre P330 Tiny (x2)**
  - Chosen for its minimal size and dual M.2 slots.
  - Can accept an additional low-profile NIC (requires PCIe riser), providing extra LAN port capabilities.
  - **Compute:**
    - Intel i5-9500 (6 Core, 6 Thread, 3.00 GHz)
    - 16GB (DDR4, 1x 16GB SODIMM)
  - **Storage:**
    - Boot/OS: 256GB NVMe
    - Data: 1TB NVMe
- **Raspberry Pi 1B+ (x1)**
  - Running as a QDevice, maintaining Proxmox cluster quorum (required for two-node clusters).
  - To be replaced and repurposed when a third Proxmox node is added.

### 🧱 Firewall

A repurposed mini-pc from a previous Proxmox cluster running [OPNsense](https://opnsense.org/get-started/).
Dedicated physical firewall appliance, using the ISP provided router as WAN gateway.

- **HP Elitedesk 800 G1 Mini**
  - **Compute:**
    - Intel i5-4590T (4 Core, 4 Thread, 2.00 GHz)
    - 10GB (DDR3, 1x 8GB, 1x 2GB SODIMM)
  - **Storage:**
    - Boot/OS: 256GB (SATA SSD)
  - **Networking:**
    - On-board NIC: WAN interface, connected to home ISP router.
    - USB NIC: LAN interface, a temporary solution until suitable replacement is made.

### 🌐 Networking

- **Switch: TP Link TL-SG108PE**
  - Basic 8 port switch, with some management features (VLANs and port mirroring).
  - Capable of PoE (Power over Ethernet), although this is not being used, and has been disabled.

---

## 🧩 Workloads

- **Firewall/Router:** Virtualized [pfSense](https://www.pfsense.org/download/) VM (for internal lab use).
- **Virtual Machines:** Management and jump host servers, self hosted CI/CD runners, test and misc utility VMs.

---

## 🛠️ Tools & Utilities

- **[Terraform](https://www.terraform.io/)**
  - Provider agnostic IaC tool, free to use, plenty of discussion, guides and support available.
  - Deploy and manage resources using dedicated providers.
  - **Alternatives:** Pulumi, OpenTofu.
- **Bash/Powershell**
  - Bootstrapping and misc utility scripts.
