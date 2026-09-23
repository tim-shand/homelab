output "group_acls" {
  description = "Output of group created."
  value = {
    for k, v in proxmox_acl.main : k => {
      role = v.role_id,
      path = v.path
    }
  }
}
