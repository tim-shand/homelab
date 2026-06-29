# Hardware & Components

This document describes the physical hardware and components used within the home lab environment.

## 🏭 Hypervisors

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

---

## 🧱 Firewall

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

---

## 🔀 Switches

**Core Switch (TP Link TL-SG108PE)**

- Basic 8 port "smart" managed switch, supporting VLANs (802.1Q and port based).
- Capable of PoE (Power over Ethernet), although this is not being used currently, and has been disabled.

---
