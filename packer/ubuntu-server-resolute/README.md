# Packer: Proxmox Template (Ubuntu Server)

## Directory Structure

```text
packer-proxmox-ubuntu/
├── ubuntu.pkr.hcl
├── variables.pkr.hcl
├── secrets.pkrvars.hcl
└── http/
    ├── user-data
    └── meta-data
```

| File                | Purpose                                                  |
| ------------------- | -------------------------------------------------------- |
| ubuntu.pkr.hcl      | Main Packer block, source "proxmox-iso" and build block. |
| variables.pkr.hcl   | Variable declarations.                                   | 
| secrets.pkrvars.hcl | Values for the variables, passed with -var-file.         | 
| http/user-data      | Subiquity autoinstall config.                            |
| http/meta-data      | Empty file; NoCloud requires it to exist.                |

