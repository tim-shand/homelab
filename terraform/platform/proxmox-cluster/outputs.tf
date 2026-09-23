output "pve_groups" {
    description = "Output of all groups created in Proxmox."
    value = {
        for k, v in module.pve_iam_group_acls : k => v.group_acls
    }
}