variable "admin_user" {
  type    = string
  default = "ubuntu_admin"
}

variable "admin_pass" {
  type      = string
  default   = "SecureP@ssw0rd!2024"
}

variable "resource_group" {
  type = string
}

variable "region" {
  type = string
}

variable "devops_agent_ip" {
  type = string
}
