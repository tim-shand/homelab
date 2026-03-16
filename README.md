# Personal Home Lab (On-Prem)

Welcome to my personal home lab! :wave:  

This project provides an environment for self-hosting and experimenting with different technologies.
A base for hands-on learning, developing knowledge and improving my skills relating to DevOps practices.
The main goal is to deploy and manage the environment using:

- Infrastructure as Code (IaC).
- Configuration as Code.
- CI/CD Pipelines for automated deployments.

As a big fan of small tech (micro-pcs, Raspberry Pi etc), a primary requirement is maintaining a small footprint for my on-prem environment. I aim to re-use as much existing hardware as possible, recycling second hand gear and giving it a new life in my lab.

![Photo of my current home lab setup.](docs/images/homelab.jpg)

---

## Documentation

Please refer to the [docs](docs/) directory for documentation on how I setup my homelab, including guides for Proxmox and OPNsense.

---

## :computer: Physical Hardware

### Hypervisors (Proxmox)

- 2x Lenovo Think Station P330 (Intel i5 9600T, 16GB DDR4, 250GB OS, 1TB ZFS pool).
  - Running clustered [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) for VMs.  
  - Currently investigating NAS options to improve high availability and failover :eyes:.
- 1x Raspberry Pi 1B+ (yes, very old)
  - Running as a QDevice, maintaining Proxmox cluster quorum.
  - Will be replaced and repurposed in future when I add a third Proxmox node.

### Networking

- **Switch:** TP-Link TL-SG108PE 8-Port Gigabit Easy Smart PoE Switch.
  - Connecting nodes physically, providing outbound access to Internet via firewall connected to home WiFi network.
- **Firewall:** HP EliteDesk G1 (Intel i5-4590T, 16 GB DDR3, 250 GB SSD).
  - Running [OPNsense](https://opnsense.org/) providing firewall, DNS, VLAN and routing functionality.
  - Separate VLANs for infrastructure, management and server workloads.

---

## :hammer_and_wrench: Deployment Tool Set

- **[Terraform](https://www.terraform.io/)**
  - Provider agnostic IaC tool, free to use, plenty of discussion, guides and support available.
  - Deploy and manage on-prem resources using dedicated providers.
  - Other considerations: Pulumi, OpenTofu.
- **GitHub Actions: Self-hosted Runners (PENDING Migration)**
  - Extends GitHub Actions workflows to allow management of on-prem environments.
  - Can be run on a dedicated VM within Proxmox.
  - Considering migration to GitLab.
- **Bash/Powershell**
  - Bootstrapping and misc utility scripts.

---

## :jigsaw: Workloads

- **Firewall/Router:** Virtualized [pfSense](https://www.pfsense.org/download/) VM (for internal lab use).
- **Virtual Machines:** Management/jump host servers, CI/CD runners, test and misc utility VMs.

---

## :memo: To Do

- [ ] Setup self-hosted GitHub Runner on-prem.
- [ ] Review details for migration to GitLab.
- [ ] Investigate Docker hosts with HA/failover.
- [ ] Investigate Kubernetes deployments.
