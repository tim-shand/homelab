# variable "pve_iam_groups" {
#     description = "Map of objects defining Proxmox groups and permissions."
#     type = map(object({
#         comment = string
#         roles_scopes = map(string)
#     }))
# }

variable "pve_iam_groups" {
    description = "Map of objects defining Proxmox groups and permissions."
    type = map(object({
        comment = string
        role    = string
        scope   = string
    }))
}
