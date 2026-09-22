# variable "pve_iam_groups" {
#     description = "Map of objects defining Proxmox groups and permissions."
#     type = map(object({
#         comment = string
#         roles_scopes = map(string)
#     }))
# }

# variable "pve_iam_groups" {
#     description = "Map of objects defining Proxmox groups and permissions."
#     type = map(object({
#         comment = string
#         role    = string
#         scope   = string
#     }))
# }

# variable "pve_iam_groups" {
#     description = "Map of objects defining Proxmox groups and permissions."
#     type = map(object({
#         comment = string
#         role    = string
#         scope   = string
#     }))
# }

variable "pve_group_name" {
    description = "Proxmox group name."
    type = string
}

variable "pve_group_comment" {
    description = "Proxmox group description (comment)."
    type = string
}

variable "pve_group_acls" {
    description = "Object defining the roles and scopes (paths) for the group permissions."
    type = map(string)
}
