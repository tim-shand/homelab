output "pve_groups" {
    description = "Output of all groups created in Proxmox."
    value = module.pve_iam_group_acls
}