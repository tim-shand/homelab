# Architecture & Design

This document covers the network architecture, design principles, and key decisions behind the lab environment. 
Configuration walkthroughs and setup guides are kept in [Configuration](./configuration.md).

---

## 🌟 Overview

The lab is architected as a dedicated zone behind an OPNsense firewall, logically isolated from the home network.
OPNsense acts as the single security enforcement point between the zones, with all inter-zone traffic subject to firewall policy.

Internal segmentation is achieved through 802.1Q VLANs, configured across OPNsense, the managed switch, and Proxmox SDN.
This ensures VLAN policy is enforced at every layer, rather than relying on any single device.

Access from the home zone into the lab is intentionally restricted.
Only trusted source addresses may reach management interfaces, on specific ports, via explicit allow rules. Everything else is default-deny.

![Home Lab Design](docs/images/homelab_architecture.png)

---

## 🌐 Networking

### Zones

| Zone | Address Space | Purpose                                               |
| ---- | ------------- | ----------------------------------------------------- |
| Home | 172.16.0.0/24 | Main home network, ISP WiFi router, personal devices. |
| Lab  | 10.0.0.0/16   | All lab networks, firewall and routing via OPNsense.  |

### VLANs

| VLAN | Name  | Subnet       | Purpose                                     | DHCP             |
| ---- | ----- | ------------ | ------------------------------------------- | ---------------- |
| 10   | MGT10 | 10.0.10.0/24 | Management, Proxmox nodes, network devices. | No - Static Only |
| 20   | SVR20 | 10.0.20.0/24 | VM and container workloads.                 | Yes (.50 to .89) |
| 99   | DMZ99 | 10.0.99.0/24 | Isolated workloads, DMZ, testing.           | Yes (.50 to .89) |

### Address Assignments

| Device     | Zone | Interface | Address      |
| ---------- | ---- | --------- | ------------ |
| ISP Router | Home | LAN       | 172.16.0.254 |
| OPNsense   | Home | WAN       | 172.16.0.250 |
| Switch     | Lab  | LAN       | 10.0.0.250   |
| OPNsense   | Lab  | LAN       | 10.0.0.254   |
| OPNsense   | Lab  | MGT10     | 10.0.10.254  |
| OPNsense   | Lab  | SVR20     | 10.0.20.254  |
| OPNsense   | Lab  | DMZ99     | 10.0.99.254  |
| Proxmox 1  | Lab  | MGT10     | 10.0.10.1    |
| Proxmox 2  | Lab  | MGT10     | 10.0.10.2    |
| Proxmox 3  | Lab  | MGT10     | 10.0.10.3    |

---

## 🧭 Design Decisions

**VLAN Segmentation (OPNsense, switch, Proxmox SDN)**

Rather than relying on firewall rules for isolation, VLANs are enforced at the hypervisor, switch, and firewall layers. 
This ensures VMs are contained within their assigned networks and avoids unauthorised access to privileged workloads.

**Static Addressing on MGT10**

The management VLAN uses static addressing only, as this is a privileged network.
Removing DHCP reduces the risk of unauthorised devices obtaining a IP addresses and reaching management interfaces.

**Outbound NAT Disabled on OPNsense**

NAT for internet-bound traffic is handled by the upstream ISP router.
Disabling outbound NAT on OPNsense avoids double-NAT and keeps OPNsense role to provide firewall and inter-VLAN routing.

**Aliases for Firewall Policy**

Firewall rules use named aliases (host groups and port groups) rather than individual IP addresses.
This allows for simplified rule management as groups of hosts or ports can be referenced within a single rule.

**ISP Router - Static Route for Lab Access**

A `/16` static route on the ISP router directs all 10.0.0.0/16 traffic towards the OPNsense WAN address.
This provides a single gateway for all lab subnets from the home zone, without exposing any lab interfaces directly on the home network. 

> [!NOTE]
> This approach is a known limitation, as it places the OPNsense WAN and home zone clients on the same broadcast domain. 
> This can trigger ICMP redirects on Linux clients specifically, causing connection state issues and requiring disabling in the kernel.
> Future state will have the home zone devices moved to a dedicated VLAN connected to a wireless access point.
> See Planned Changes for future details.

---

## 🏢 Hypervisor Cluster

The cluster consists of three physical Proxmox VE hosts. 
Each node's primary NIC is connected to the managed switch on ports 2, 3, and 4 (VLAN10/MGT10). 
Two of the three nodes have a secondary NIC connected on ports 5 and 6, used for dedicated VM workload VLAN traffic.

Prior to the third node being added, a Raspberry Pi running as a QDevice provided the missing quorum vote required for a two-node cluster. 
This has since been decommissioned, pending repurposing.

> [!TIP]
> Setup and configuration guides for Proxmox are available on my [website](https://tshand.com/tags/homelab/).

![Screenshot of Proxmox cluster nodes.](images/proxmox_cluster_01.png)

### Software Defined Networking (SDN)

Proxmox SDN is used to define and manage virtual networks for VMs and containers across the cluster. 
Rather than tagging each VM individually, resources are assigned to a pre-tagged VNet.
The VLAN tag is inherited from the VNet itself, centralising VLAN assignment and reducing the risk of misconfiguration at the VM level.

This simplifies network management and reduces manual VLAN configuration, as the VLAN tag IDs can be assigned to the entire VNet.

- **Zones:** Define the SDN backend (`Simple`, `VLAN`, `VXLAN`, `EVPN`) and determine how virtual networks are implemented across the cluster.
- **VNets:** The virtual networks that VMs and containers are connected to. Each VNet belongs to a single zone and carries a VLAN tag.
- **Subnets:** Define the IP addressing for a VNet, including gateway information and IP address management (IPAM). Each subnet belongs to a single VNet.

> [!NOTE]
> Proxmox SDN configuration, including zones, VNets, and subnets, is defined and managed via Terraform.

---

## 🌍 Edge Router (ISP WiFi Router)

The ISP-provided router is the home network gateway providing NAT, DHCP, and internet access for home-zone devices.
From the lab perspective, everything connected to the ISP router is considered WAN-side.

The OPNsense WAN interface is connected to the ISP router via Ethernet and receives a fixed address via a DHCP reservation, ensuring the address used
in the static route remains consistent.

### Static Route

A `/16` static route on the ISP router sends all 10.0.0.0/16 traffic to the OPNsense WAN address (172.16.0.250), covering all current and
future lab subnets.

**Traffic Flow: Laptop to Lab resources:**

```text
Laptop (172.16.0.10)
    │
ISP Router (172.16.0.254)
  [static route: 10.0.0.0/16 --> 172.16.0.250]
    │
OPNsense WAN (172.16.0.250)
    │
OPNsense LAN (10.0.0.254)
    ├── VLAN10/MGT10 (10.0.10.0/24)
    ├── VLAN20/SVR20 (10.0.20.0/24)
    └── VLAN99/DMZ99 (10.0.99.0/24)
```

---

## 🧱 Firewall (OPNsense)

### Alias Groups

Aliases are used to group common hosts or ports, making the generation of firewall rules much easier.
Rather than assigning a rule per host and per port, alias groups enable a single rule to apply to multiple hosts across multiple ports.

> [!TIP]
> If a host is added or the address changes, only the alias require updated, not individual firewall rules.

| Name              | Type      | Content                         | Description         |
| ----------------- | --------- | ------------------------------- | ------------------- |
| WAN_Trusted       | Host(s)   | 172.16.0.10, 172.16.0.11        | WAN Trusted Devices |
| MGT_Hosts_Proxmox | Host(s)   | 10.0.10.1, 10.0.10.2, 10.0.10.3 | Proxmox Nodes       |
| MGT_Hosts_Network | Host(s)   | 10.0.10.250, 10.0.10.254        | Network Devices     |
| Ports_Mgmt        | Port(s)   | 22, 80, 443, 8006               | Management Ports    |
| Ports_Web         | Port(s)   | 80, 443                         | Web Only Ports      |

### Firewall Rules (WAN Interface)

Inbound rules on the WAN interface restrict home-zone access to specific destinations and ports.
All other inbound traffic is denied by the default deny.
This protects the lab network from un-trusted devices such as IOT devices (TVs and automated cat toilets).

| Action | Interface | Version | Protocol | Source      | Port | Destination       | Port       |
| ------ | --------- | ------- | -------- | ----------- | ---- | ----------------- | ---------- |
| PASS   | WAN       | IPv4    | ICMP     | WAN_Trusted | *    | MGT_Hosts_Proxmox | *          |
| PASS   | WAN       | IPv4    | ICMP     | WAN_Trusted | *    | MGT_Hosts_Network | *          |
| PASS   | WAN       | IPv4    | TCP/UDP  | WAN_Trusted | *    | MGT_Hosts_Proxmox | Ports_Mgmt |
| PASS   | WAN       | IPv4    | TCP/UDP  | WAN_Trusted | *    | MGT_Hosts_Network | Ports_Web  |

### VLANs

OPNsense hosts each VLAN as a child interface on the LAN parent, providing a gateway address and enforcing inter-VLAN firewall policy.
This helps to reduce network congestion and adds an extra layer of security by keeping management and workload traffic separated on their own networks.

| Device  | Parent       | VLAN Tag | VLAN Priority                | Description |
| ------- | ------------ | -------- | ---------------------------- | ----------- |
| vlan010 | igc0 \[LAN\] | 10       | Network Control (7, highest) | MGT10       |
| vlan020 | igc0 \[LAN\] | 20       | Best Effort (0, default)     | SVR20       |
| vlan099 | igc0 \[LAN\] | 99       | Best Effort (0, default)     | DMZ99       |

![Screenshot of OPNsense VLAN setup.](images/opnsense_vlans_01.png)

---

## 🔀 Managed Switch

This device is the backbone of the lab network. It is used to connect devices, configure VLANs and carry network traffic.
VLANs are configured to carry traffic on ports marked as both `tagged` and `untagged`.

- **Tagged:** Ethernet frame contains a VLAN ID in its header. 
  - Used between VLAN-aware devices (VMs, switches, wireless APs, routers).
- **Untagged:** Ethernet frame has no VLAN ID in its header.
  - The switch uses the PVID (Port VLAN ID) to decide which VLAN to assign the frame to.
  - Setting untagged VLAN ID for workload ports (5, 6, 7) to 99, keeping them off default of ID 1.

VLAN tagging is used to ensure each port carries only the VLANs relevant to the device connected to it.

- **Port 1:** Uplink trunk to OPNsense carrying all VLANs tagged.
- **Ports 2-4:** Carry MGT10 untagged to the Proxmox nodes (PVID 10) without requiring the nodes to have `VLAN-aware` enabled on their primary NIC.
- **Ports 5-7:** Carry tagged workload VLANs, used by nodes with a secondary workload NIC.
- **Port 8:** Used for access to default VLAN 1 (LAN) in case of accidental lockout due to misconfigured firewall rules.

### 802.1Q VLAN Membership

| VLAN ID  | VLAN Name | Member Ports | Tagged | Untagged |
| -------- | --------- | ------------ | ------ | -------- |
| 1        | Default   | 1, 8         |        | 1, 8     |
| 10       | MGT10     | 1-4          | 1      | 2-4      |
| 20       | SVR20     | 1, 5-7       | 1, 5-7 |          |
| 99       | DMZ99     | 1, 5-7       | 1, 5-7 |          |

### 802.1Q PVID (Port VLAN ID)

The PVID defines the default VLAN ID assigned to any **untagged** traffic on the specified port.

| Port     | 1   | 2   | 3   | 4   | 5   | 6   | 7   | 8   |
| -------- | --- | --- | --- | --- | --- | --- | --- | --- |
| **PVID** | 1   | 10  | 10  | 10  | 99  | 99  | 99  | 1   |

---

## 🔭 Planned Changes

### Home-Zone Migration to Dedicated AP and VLAN

The current architecture places the OPNsense WAN interface and home-zone clients on the same broadcast domain (172.16.0.0/24). 
This creates a triangle-like routing situation where the ISP router can issue ICMP redirects to home-zone clients, telling them to route lab-bound traffic directly to
OPNsense rather than via the ISP router. 

It has been observed that Linux devices respect these redirects and rewrite their route cache accordingly.
This seems to cause intermittent connectivity failures to lab management interfaces.
The issue has been temporarily resolved using a "bandaid fix" by disabling ICMP redirect acceptance on Linux laptops.

The planned solution is to move home-zone devices behind OPNsense entirely via a dedicated wireless AP.
This will be served on a new VLAN (HME50,10.0.50.0/24). 

With OPNsense as the new default gateway for home devices, there is no second router to redirect traffic, removing the need for workarounds.

**Additional VLANs planned for the new Access Point:**

| VLAN | Name  | Subnet       | Purpose                                 |
| ---- | ----- | ------------ | --------------------------------------- |
| 50   | HME50 | 10.0.50.0/24 | Personal home devices.                  |
| 60   | IOT60 | 10.0.60.0/24 | IoT devices, TVs, cat toilet, etc.      |
| 70   | CAM70 | 10.0.70.0/24 | Security cameras, monitoring devices.   |
| 80   | GST80 | 10.0.80.0/24 | Guest network, isolated, Internet only. |

Once the new AP is in place, the ISP router static route will be removed.
The `WAN_Trusted` alias and WAN interface firewall rules will be replaced by inter-VLAN rules on the HME50 interface.
