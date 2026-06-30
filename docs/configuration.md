# Configuration & Settings

This document describes the configuration and settings used within the home lab environment.

---

Proxmox

Post-install hardening steps (repository configuration, subscription nag removal etc.)
Cluster creation and node join process
SDN setup — zone, VNet, and subnet creation, referencing architecture.md for the what and explaining the how here
ZFS pool creation
QDevice setup (historical — worth keeping as it's documented on your blog and cross-referenced)

Terraform

Provider setup (bpg/proxmox configuration, authentication)
The two-applier pattern for SDN management — this is nuanced enough to warrant its own subsection
When the finalizer applier is and isn't needed
Workflow — how to plan/apply, state management, any CI/CD pipeline integration

---

## Hypervisors (Proxmox)

> [!TIP]
> Full guide to Proxmox installation and setup can be found [here](https://tshand.com/posts/homelab-03-proxmox-install/#overview).

### Disable Enterprise Repositories

To avoid errors when performing updates, disable the Enterprise repositories. 
Operating system updates for Debian will still be made available for install, however Proxmox specific updates will not be available.

1. Select the Proxmox node from the left-side panel and navigate to `Updates > Repositories`.
2. Select each of the `Enterprise repositories`, then click `Disable`.

![Screenshot showing the disabling of Proxmox enterprise repositories.](docs/images/proxmox_disable_repos.png)

---

## 🌍 Edge Router (ISP Router)

### DHCP Reservation

Static DHCP reservation to ensure that the address of the OPNsense WAN interface is preserved. 

1. Navigate to `Network > LAN > LAN DHCP`.
2. Click `Add` button under the existing table.
3. Populate fields as below:

| Setting         | Value             |
| --------------- | ----------------- |
| Enable          | Yes               |
| MAC Address     | 00:23:24:xx:xx:xx |
| IP Address      | 172.16.0.250      |
| Hostname        | inf-net-fwl-01    |

4. Click `Save Settings`.

### Static Route

Provides a pathway for WAN-side devices where the target destination address is within the home lab network.

1. Navigate to `Network > Routing > Static Route`.
2. Enable the option `Static Route Activation` (if disabled).
3. Click `Add Static Route` button.
4. Populate fields as below:

| Setting         | Value        |
| --------------- | ------------ |
| Enable          | Yes          |
| Network Address | 10.0.0.0     |
| Subnet Mask     | 255.255.0.0  |
| Gateway         | 172.16.0.250 |
| Interface       | LAN          |

5. Click `Save Settings`.

---

## 🧱 Firewall (OPNsense)

> [!TIP]
> Full guide to OPNsense installation and setup can be found [here](https://tshand.com/posts/homelab-02-firewall-setup/).

### Outbound NAT

Outbound NAT is disabled in OPNsense to prevent "double NAT", as the upstream ISP router provides the NAT functionality for outbound Internet access.

1. Navigate to `Firewall > NAT > Outbound`.
2. Select the option `Disable outbound NAT rule generation`.
3. Click `Save` button, followed by `Apply Changes`.

### Reply-To

During testing, disabling reply-to caused connectivity issues for home-zone to lab-zone connectivity via WAN interface.

1. Navigate to `Firewall > Settings > Advanced`.
2. Disable (uncheck) the option `Disable reply-to on WAN rules` (if enabled).
3. Click `Save` button, followed by `Apply Changes`.

### Alias Groups

Aliases are used to group common hosts or ports, simplifying firewall rule creation.

1. Navigate to `Firewall > Aliases`.
2. Click the `+` button to create a new Alias.
3. Populate the required fields and click the `Save` button.
4. Repeat for each required alias.
5. Once complete, click the `Apply` button.

| Name              | Type      | Content                         | Description         |
| ----------------- | --------- | ------------------------------- | ------------------- |
| WAN_Trusted       | Host(s)   | 172.16.0.10, 172.16.0.11        | WAN Trusted Devices |
| MGT_Hosts_Proxmox | Host(s)   | 10.0.10.1, 10.0.10.2, 10.0.10.3 | Proxmox Nodes       |
| MGT_Hosts_Network | Host(s)   | 10.0.10.250, 10.0.10.254        | Network Devices     |
| Ports_Mgmt        | Port(s)   | 22, 80, 443, 8006               | Management Ports    |
| Ports_Web         | Port(s)   | 80, 443                         | Web Only Ports      |

### Firewall Rules

1. Navigate to `Firewall > Rules [new]`.
2. Click the `+` button to create a new rule.
3. Use alias groups for hosts and ports where possible for simplicity.
4. Once populated, click the `Save` button, followed by `Apply`.

- Inbound from trusted WAN devices to Proxmox on ICMP.
- Inbound from trusted WAN devices to network devices on ICMP.
- Inbound from trusted WAN devices to Proxmox on management ports.
- Inbound from trusted WAN devices to network devices on web only ports.

| Action | Interface | Version | Protocol | Source      | Port | Destination       | Port       |
| ------ | --------- | ------- | -------- | ----------- | ---- | ----------------- | ---------- |
| PASS   | WAN       | IPv4    | ICMP     | WAN_Trusted | *    | MGT_Hosts_Proxmox | *          |
| PASS   | WAN       | IPv4    | ICMP     | WAN_Trusted | *    | MGT_Hosts_Network | *          |
| PASS   | WAN       | IPv4    | TCP/UDP  | WAN_Trusted | *    | MGT_Hosts_Proxmox | Ports_Mgmt |
| PASS   | WAN       | IPv4    | TCP/UDP  | WAN_Trusted | *    | MGT_Hosts_Network | Ports_Web  |

### VLANs

1. Navigate to `Interfaces > Assignments`.
2. Take note of the device connected to the LAN interface. This will be used as the parent for the VLAN assignments.
3. Navigate to `Devices > VLAN`.
4. Click the `+` button to create a new VLAN.
5. Enter the VLAN name (starting with `vlan0`), providing a tag ID number and description.
6. Ensure to select the LAN device from step 2 as the parent of this interface.
7. Click `Save` to create the VLAN interface.
8. Repeat this process for all required VLANs.

| Device  | Parent       | VLAN Tag | VLAN Priority                | Description |
| ------- | ------------ | -------- | ---------------------------- | ----------- |
| vlan010 | igc0 \[LAN\] | 10       | Network Control (7, highest) | MGT10       |
| vlan020 | igc0 \[LAN\] | 20       | Best Effort (0, default)     | SVR20       |
| vlan099 | igc0 \[LAN\] | 99       | Best Effort (0, default)     | DMZ99       |

9. When all VLANs have been added, click `Apply`.
10. Navigate to `Interfaces > Assignments`.
11. Under the section `Assign a new interface`, select the first VLAN interface.
12. Provide a description in the text box provided. This will be used as the display name for the interface.
13. Repeat this process until all VLANs have been assigned.
14. Navigate to `Interfaces > [SELECT VLAN]`.
15. Enable the interface using the check box provided.
15. Set the IPv4 Configuration Type to `Static IPv4`.
16. Enter an IP address to be used by the VLAN gateway, including the subnet mask.
17. Click `Save`, followed by `Apply Changes`.

![Screenshot of OPNsense VLAN setup.](images/opnsense_vlans_01.png)

### DHCP

**Enable DHCP listener for VLANs:** 

1. Navigate to `Services > Dnsmasq DNS & DHCP > General`.
2. Under the `Interface` drop down, select all interfaces that require DHCP.
3. Scroll down and click `Apply`.

**Configure DHCP scopes per VLAN:**

1. Navigate to `Services > Dnsmasq DNS & DHCP > DHCP Ranges`.
2. Click the `+` icon to create a new DHCP range.
3. Select the VLAN interface, providing both a starting and ending IP address with optional domain name.
4. All other setting can be left as defaults.
5. Click `Save`. Repeat for each of the remaining VLANs.
6. Once all VLAN DHCP ranges have been added, click `Apply`.

> [!NOTE]
> DHCP is not used for the MGT10 VLAN. Being a privileged management network, it uses static addressing only.

| Interface  | Start Address | End Address | Domain         | Description  |
| ---------- | ------------- | ----------- | -------------- | ------------ |
| LAN        | 10.0.0.50     | 10.0.0.89   | lan.tshand.net | LAN - DHCP   |
| vlan020    | 10.0.20.50    | 10.0.20.89  | svr.tshand.net | SVR20 - DHCP |
| vlan099    | 10.0.99.50    | 10.0.99.89  | dmz.tshand.net | DMZ99 - DHCP |

![Screenshot of OPNsense DHCP configuration.](images/opnsense_dhcp_01.png)

---

## 🔀 Managed Switch

VLANs are configured to carry traffic on ports marked as both `tagged` and `untagged`.

- **Tagged:** Ethernet frame contains a VLAN ID in its header, VLAN-aware devices.
- **Untagged:** Ethernet frame has no VLAN ID in its header, uses PVID (Port VLAN ID).

### 802.1Q VLAN Settings

| VLAN ID  | VLAN Name | Member Ports | Tagged | Untagged |
| -------- | --------- | ------------ | ------ | -------- |
| 1        | Default   | 1, 8         |        | 1, 8     |
| 10       | MGT10     | 1-4          | 1      | 2-4      |
| 20       | SVR20     | 1, 5-7       | 1, 5-7 |          |
| 99       | DMZ99     | 1, 5-7       | 1, 5-7 |          |

### 802.1Q PVID Settings

| Port     | 1   | 2   | 3   | 4   | 5   | 6   | 7   | 8   |
| -------- | --- | --- | --- | --- | --- | --- | --- | --- |
| **PVID** | 1   | 10  | 10  | 10  | 99  | 99  | 99  | 1   |

![Screenshot of TP Link switch VLAN setup.](images/switch_vlans_01.png)
