# Personal Home Lab

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
- The firewall WAN address is provided by the ISP router using a DHCP reservation.
- Virtual server workloads are isolated on dedicated VLANs for improved security and network traffic control.

> [!NOTE]
> Further details on architecture and design can be found in the [Architecture](/docs/architecture.md) documentation.

![Home Lab Design](docs/images/homelab_architecture.png)

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

Refer to the [docs](docs/) directory for more information covering operations, configuration and design.

| Name                                    | Purpose                                       |
| --------------------------------------- | --------------------------------------------- |
| [Architecture](/docs/architecture.md)   | Topology, VLANs, SDN design.                  |
| [Hardware](/docs/hardware.md)           | Device specs, upgrades, expansion.            |
| [Configuration](/docs/configuration.md) | Proxmox, OPNsense, switch config, automation. |
